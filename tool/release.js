#!/usr/bin/env node
//
// release.js — cut a BrewPath release.
//
// Performs the TestFlight/App Store release ritual in one step:
//   1. Bumps the version in pubspec.yaml (always bumps the build
//      number; optionally bumps the semantic version).
//   2. Stamps the "## [Unreleased]" section of docs/CHANGELOG.md with the new
//      version and today's date, and opens a fresh empty Unreleased block.
//   3. (with --commit) commits both files and creates an annotated git tag.
//
// Usage (run from the repo root):
//   node tool/release.js [patch|minor|major|X.Y.Z] [--commit] [--dry-run] [--allow-empty]
//
//   (no version arg)   bump build number only           1.0.0+1 -> 1.0.0+2
//   patch              bump patch + build               1.0.0+1 -> 1.0.1+2
//   minor              bump minor (reset patch) + build  1.0.0+1 -> 1.1.0+2
//   major              bump major (reset minor/patch)    1.0.0+1 -> 2.0.0+2
//   X.Y.Z              set explicit semver + build       ->       X.Y.Z+2
//
//   --dry-run          print what would change; write nothing
//   --commit           git add + commit + annotated tag after editing
//   --allow-empty      allow a release even when [Unreleased] has no entries

"use strict";

const fs = require("node:fs");
const path = require("node:path");
const { execFileSync } = require("node:child_process");

// Repo-relative paths of the two files a release touches.
const PUBSPEC_RELATIVE_PATH = "pubspec.yaml";
const CHANGELOG_RELATIVE_PATH = "docs/CHANGELOG.md";

// Matches the first `version: X.Y.Z+B` line in pubspec.yaml, capturing the
// value after the colon.
const PUBSPEC_VERSION_LINE = /^version:[ \t]*(.+)$/m;

// Parses a `X.Y.Z+B` version string into [major, minor, patch, build].
const VERSION_STRING = /^(\d+)\.(\d+)\.(\d+)\+(\d+)$/;

// Validates an explicit `X.Y.Z` version passed as a CLI argument.
const EXPLICIT_SEMVER_ARG = /^\d+\.\d+\.\d+$/;

// Matches the lone `## [Unreleased]` heading line (the changelog stamp anchor).
const UNRELEASED_HEADING_LINE = /^## \[Unreleased\]\n/m;

// Within the [Unreleased] section, detects at least one `- ` list entry.
const UNRELEASED_ENTRY = /^\s*-\s/m;

// Isolates the body between the `## [Unreleased]` heading and the next `## `
// heading, capturing everything in between.
const UNRELEASED_SECTION_BODY = /^## \[Unreleased\]\n([\s\S]*?)(?=^## )/m;

/** Builds the replacement block that re-opens an empty [Unreleased] above the
 * freshly dated version heading. The existing entries that followed the old
 * heading slide down under `## [version] — date`. */
function changelogStamp(version, date) {
  return (
    "## [Unreleased]\n\n" +
    "### Added\n\n### Changed\n\n### Fixed\n\n" +
    "---\n\n" +
    `## [${version}] — ${date}\n`
  );
}

/** Runs a git command at `repoRoot`, returning trimmed stdout. Throws (with the
 * git stderr surfaced) on a non-zero exit. */
function git(repoRoot, args) {
  return execFileSync("git", ["-C", repoRoot, ...args], {
    encoding: "utf8",
  }).trim();
}

/** Exits the process with a one-line stderr message. */
function fail(message) {
  process.stderr.write(`error: ${message}\n`);
  process.exit(1);
}

/** Parses argv into { bumpKind, dryRun, doCommit, allowEmpty }. `bumpKind` is
 * one of 'patch' | 'minor' | 'major' | an explicit 'X.Y.Z' | null (build only). */
function parseArgs(argv) {
  let bumpKind = null;
  let dryRun = false;
  let doCommit = false;
  let allowEmpty = false;

  for (const arg of argv) {
    if (arg === "--dry-run") {
      dryRun = true;
    } else if (arg === "--commit") {
      doCommit = true;
    } else if (arg === "--allow-empty") {
      allowEmpty = true;
    } else if (arg === "patch" || arg === "minor" || arg === "major") {
      bumpKind = arg;
    } else if (EXPLICIT_SEMVER_ARG.test(arg)) {
      bumpKind = arg;
    } else {
      fail(`unknown argument '${arg}'`);
    }
  }

  return { bumpKind, dryRun, doCommit, allowEmpty };
}

/** Resolves the git root and the absolute paths of the files to edit. */
function resolveRepoPaths() {
  const repoRoot = execFileSync("git", ["rev-parse", "--show-toplevel"], {
    encoding: "utf8",
  }).trim();

  const pubspecPath = path.join(repoRoot, PUBSPEC_RELATIVE_PATH);
  const changelogPath = path.join(repoRoot, CHANGELOG_RELATIVE_PATH);

  if (!fs.existsSync(pubspecPath)) {
    fail(`${pubspecPath} not found`);
  }

  if (!fs.existsSync(changelogPath)) {
    fail(`${changelogPath} not found`);
  }

  return { repoRoot, pubspecPath, changelogPath };
}

/** Reads the current `X.Y.Z+B` version string from pubspec.yaml. */
function readCurrentVersion(pubspecPath) {
  const match = fs
    .readFileSync(pubspecPath, "utf8")
    .match(PUBSPEC_VERSION_LINE);
  if (!match) {
    fail(`no 'version:' line found in ${pubspecPath}`);
  }

  const currentVersion = match[1].replace(/\s/g, "");
  if (!VERSION_STRING.test(currentVersion)) {
    fail(`current version '${currentVersion}' is not in X.Y.Z+B form`);
  }

  return currentVersion;
}

/** Computes the next version string. The build number always increments by one;
 * the semantic version moves only when `bumpKind` is set. */
function computeNextVersion(currentVersion, bumpKind) {
  const [, majorText, minorText, patchText, buildText] =
    currentVersion.match(VERSION_STRING);
  let major = Number(majorText);
  let minor = Number(minorText);
  let patch = Number(patchText);

  if (bumpKind === "patch") {
    patch += 1;
  } else if (bumpKind === "minor") {
    minor += 1;
    patch = 0;
  } else if (bumpKind === "major") {
    major += 1;
    minor = 0;
    patch = 0;
  } else if (bumpKind !== null) {
    [major, minor, patch] = bumpKind.split(".").map(Number);
  }

  const newBuildNumber = Number(buildText) + 1;
  return `${major}.${minor}.${patch}+${newBuildNumber}`;
}

/** Whether the [Unreleased] section contains at least one `- ` entry. */
function hasUnreleasedEntries(changelogText) {
  const section = changelogText.match(UNRELEASED_SECTION_BODY);

  return section !== null && UNRELEASED_ENTRY.test(section[1]);
}

/** Replaces the first `version:` line in pubspec.yaml with the new version. */
function updatePubspecVersion(pubspecPath, newVersion) {
  const updated = fs
    .readFileSync(pubspecPath, "utf8")
    .replace(PUBSPEC_VERSION_LINE, `version: ${newVersion}`);

  fs.writeFileSync(pubspecPath, updated);
}

/** Re-opens an empty [Unreleased] and inserts the dated version heading. */
function stampChangelog(changelogPath, newVersion, date) {
  const updated = fs
    .readFileSync(changelogPath, "utf8")
    .replace(UNRELEASED_HEADING_LINE, changelogStamp(newVersion, date));

  fs.writeFileSync(changelogPath, updated);
}

/** Commits the two edited files and creates an annotated tag. */
function commitAndTag(repoRoot, pubspecPath, changelogPath, newVersion) {
  const tag = `v${newVersion}`;

  git(repoRoot, ["add", pubspecPath, changelogPath]);
  git(repoRoot, ["commit", "-m", `chore(release): ${newVersion}`]);
  git(repoRoot, ["tag", "-a", tag, "-m", `Release ${newVersion}`]);

  process.stdout.write(`Committed and tagged ${tag}.\n`);
}

/** Today's date as `YYYY-MM-DD` in local time (matches `date +%Y-%m-%d`). */
function localDate() {
  const now = new Date();
  const year = now.getFullYear();
  const month = String(now.getMonth() + 1).padStart(2, "0");
  const day = String(now.getDate()).padStart(2, "0");

  return `${year}-${month}-${day}`;
}

function main() {
  const { bumpKind, dryRun, doCommit, allowEmpty } = parseArgs(
    process.argv.slice(2),
  );
  const { repoRoot, pubspecPath, changelogPath } = resolveRepoPaths();

  const currentVersion = readCurrentVersion(pubspecPath);
  const newVersion = computeNextVersion(currentVersion, bumpKind);
  const date = localDate();
  const tag = `v${newVersion}`;

  // Refuse to release nothing: after a release [Unreleased] is empty, so a
  // re-run would otherwise bump the build number for no reason.
  const changelogText = fs.readFileSync(changelogPath, "utf8");
  if (!allowEmpty && !hasUnreleasedEntries(changelogText)) {
    fail(
      "[Unreleased] has no entries — nothing to release.\n" +
        "       Run /changelog first, or pass --allow-empty for a build-only re-release.",
    );
  }

  process.stdout.write(
    `Current version : ${currentVersion}\n` +
      `New version     : ${newVersion}\n` +
      `Changelog stamp : ## [${newVersion}] — ${date}\n` +
      `Git tag         : ${tag}\n\n`,
  );

  if (dryRun) {
    process.stdout.write("[dry-run] no files changed.\n");

    return;
  }

  updatePubspecVersion(pubspecPath, newVersion);
  stampChangelog(changelogPath, newVersion, date);
  process.stdout.write(`Updated ${pubspecPath} and ${changelogPath}.\n`);

  if (doCommit) {
    commitAndTag(repoRoot, pubspecPath, changelogPath, newVersion);
  } else {
    process.stdout.write(
      "\nNext steps (not done automatically — review first):\n" +
        `  git add "${pubspecPath}" "${changelogPath}"\n` +
        `  git commit -m "chore(release): ${newVersion}"\n` +
        `  git tag -a "${tag}" -m "Release ${newVersion}"\n`,
    );
  }
}

main();
