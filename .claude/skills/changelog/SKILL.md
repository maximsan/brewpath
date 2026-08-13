---
name: changelog
description: Use when updating docs/CHANGELOG.md — drafts curated Unreleased entries from recent code changes (git diffs), not from commit messages. Invoke explicitly as /changelog or when the user asks to record/log what changed.
---

# Changelog Skill

You are updating `docs/CHANGELOG.md` for BrewPath. Work from the actual code
changes, NOT from commit messages (the commit messages in this repo are often
vague, e.g. "update other tabs").

## Steps

1. **Find the range of un-logged changes.** The range is **since the latest tag** — `git describe --tags --abbrev=0`, then `git log <tag>..HEAD`. A tag is the last point the changelog is known to have been reconciled, because that is what `release.js` stamps.
   - Only if the repo has **no tags at all**, fall back to commits since `docs/CHANGELOG.md` was last modified (`git log -1 --format=%H -- docs/CHANGELOG.md`).
   - **Never let the fallback narrow the tag range.** The file gets touched by moves, renames and doc sweeps that add no entries, so "last modified" can sit far ahead of "last reconciled" — in Aug 2026 the two disagreed by 26 commits, and the newer one hid two months of unlogged work.
   - **A long range means a backlog, not an error.** If the range spans many commits or weeks, expect that earlier work was never logged: audit the whole range and say how far back the gap goes, rather than logging only the recent end of it.
   - Also include uncommitted work: check `git status` and `git diff` for staged/unstaged changes worth logging.

2. **Read the real changes**, not just the log. Use `git diff --stat <range>` to see what files moved, then inspect diffs of the non-trivial ones. Look first at `lib/`, `assets/content/`, `pubspec.yaml`, `ios/`, and `.github/`, then at the developer-facing docs (`docs/`, `README.md`, `CLAUDE.md` / `AGENTS.md`, `.claude/skills/`, `learning/`, and the design source under `brew-path/`). **This is where to look, not a whitelist** — step 3 is the only exclusion list.

3. **Filter out noise.** Do NOT log: pure refactors, formatting, test-only changes, generated files (`*.g.dart`, `*.freezed.dart`, anything under `build/` or `.dart_tool/`), or work-in-progress that was later reverted in the same range.
   - **Documentation counts when it documents the product, not the process** — and then as a recap: one short bullet naming the main idea, never a file-by-file account. In: the design reference and its source prototype, the syllabus or content model, anything recording what the app is or should be. Out: internal working documentation, which serves whoever is doing the work today rather than the project's record — git and `gh` workflow notes, agent instructions, ADRs, plans, research notes, and the `CLAUDE.md` / `AGENTS.md` conventions themselves. Wording stays out either way: typos, phrasing, reflowing, and sweeps that only rename something (log the rename itself, once).

4. **Categorize** what's left into **Added / Changed / Fixed / Removed**. Write one short, plain-language bullet per change describing the user- or developer-visible effect — the kind of line that helps a forgetful future reader, not an implementation note.

5. **Show the proposed bullets to the user and wait for approval.** Do not edit the file yet.

6. **On approval, merge into the `## [Unreleased]` section** of `docs/CHANGELOG.md` — add to the existing Added/Changed/Fixed lists, do not create duplicate headings, and do not duplicate bullets that are already there. Leave the `## Build Milestones` table untouched.

7. **Never edit a dated version section.** Everything under a `## [x.y.z] — date` heading is frozen: it records what shipped in that build. A rename or a restructure will leave old entries naming files and paths that no longer exist (`coffee_quest/tool/release.sh`), and that is correct — editing them to match today's tree would make the history describe a state that never existed. Log the rename or move once under `[Unreleased]` so a reader of an old section can follow it forward.

## Notes

- Keep the Keep a Changelog format already in the file.
- If the range has nothing log-worthy, say so plainly instead of inventing entries.
- To cut a release (stamp Unreleased with a version + date, bump pubspec, tag), point the user to `node tool/release.js` — that's a separate step, not this skill's job.
