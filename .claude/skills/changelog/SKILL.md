---
name: changelog
description: Use when updating docs/CHANGELOG.md — drafts curated Unreleased entries from recent code changes (git diffs), not from commit messages. Invoke explicitly as /changelog or when the user asks to record/log what changed.
---

# Changelog Skill

You are updating `docs/CHANGELOG.md` for BrewPath. Work from the actual code
changes, NOT from commit messages (the commit messages in this repo are often
vague, e.g. "update other tabs").

## Steps

1. **Find the range of un-logged changes.**
   - If git tags exist: use commits since the latest tag — `git describe --tags --abbrev=0` then `git log <tag>..HEAD`.
   - Otherwise: use commits since `docs/CHANGELOG.md` was last modified — find that commit with `git log -1 --format=%H -- docs/CHANGELOG.md`, then `git log <commit>..HEAD`.
   - Also include uncommitted work: check `git status` and `git diff` for staged/unstaged changes worth logging.

2. **Read the real changes**, not just the log. Use `git diff --stat <range>` to see what files moved, then inspect diffs of the non-trivial ones. Focus on `lib/`, `assets/content/`, `pubspec.yaml`, `ios/`, and `.github/`.

3. **Filter out noise.** Do NOT log: pure refactors, formatting, test-only changes, generated files (`*.g.dart`, `*.freezed.dart`, anything under `build/` or `.dart_tool/`), or work-in-progress that was later reverted in the same range.

4. **Categorize** what's left into **Added / Changed / Fixed / Removed**. Write one short, plain-language bullet per change describing the user- or developer-visible effect — the kind of line that helps a forgetful future reader, not an implementation note.

5. **Show the proposed bullets to the user and wait for approval.** Do not edit the file yet.

6. **On approval, merge into the `## [Unreleased]` section** of `docs/CHANGELOG.md` — add to the existing Added/Changed/Fixed lists, do not create duplicate headings, and do not duplicate bullets that are already there. Leave the `## Build Milestones` table untouched.

## Notes

- Keep the Keep a Changelog format already in the file.
- If the range has nothing log-worthy, say so plainly instead of inventing entries.
- To cut a release (stamp Unreleased with a version + date, bump pubspec, tag), point the user to `node tool/release.js` — that's a separate step, not this skill's job.
