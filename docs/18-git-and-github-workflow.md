# Git & GitHub Workflow

The `git` and `gh` commands this project actually uses, and the reasoning behind
the non-obvious ones. Flutter/Dart commands live in [`../README.md`](../README.md);
the issue-tracker conventions for `/wayfinder` live in
[`agents/issue-tracker.md`](agents/issue-tracker.md); CI is described in
[`13-ci-cd.md`](13-ci-cd.md).

Every command below is copy-pasteable from the repo root.

---

## Commit messages

Use a heredoc with a **quoted** `'EOF'`. Commit bodies are full of backticks,
`$`, and quotes; unquoted, the shell expands them and a stray backtick executes
a command.

```bash
git commit -F - <<'EOF'
Subject line, imperative mood, no trailing period

Body explaining why, not what. Backticks like `package:brew_path/…` and
$variables are safe because EOF is quoted.

Closes #35
EOF
```

`Closes #<n>` auto-closes the issue **on merge**. `Refs #<n>` links without
closing — if you use `Refs`, the issue needs closing by hand.

## Staging with exclusions

```bash
git add -A -- . ':!.claude/worktrees'
```

The `':!<path>'` pathspec excludes a directory from an otherwise-everything add.
`.claude/worktrees/` — which holds full working copies of this repo, 1.3 GB of
them — is now in `.gitignore`, so the exclusion above is no longer required for
it. Keep the form in mind for the general case: any large untracked directory
that is not yet ignored will otherwise be swept in by `git add -A`.

The durable lesson is the other way round: when `git add -A` would capture
something surprising, **the fix is `.gitignore`, not a habit of remembering a
pathspec.** A rule the tooling enforces beats one every future commit has to
recall.

## Diffing — the trap that matters

```bash
git diff main            # working tree vs main — includes UNCOMMITTED work
git diff main...HEAD     # merge-base vs HEAD — COMMITTED work only
```

**These are not interchangeable.** With work still uncommitted on a fresh
branch, `main...HEAD` is empty — a review run against it silently reviews
nothing and reports a clean bill of health. Check before you rely on it:

```bash
git log main..HEAD --oneline | wc -l    # 0 commits? then use `git diff main`
```

Against the remote, always fetch first — comparing to `main` compares to your
possibly-stale local copy:

```bash
git fetch origin
git log --oneline origin/main..HEAD     # exactly what a PR would contain
```

## Repo-wide search and replace, tracked files only

```bash
git ls-files -z | xargs -0 grep -In "pattern"
git ls-files -z -- '*.dart' | xargs -0 sed -i '' 's|old|new|g'
```

`git ls-files` restricts the operation to **tracked** files, which is what you
almost always want here — it skips `build/`, `.dart_tool/`, `google_fonts/` and
the untracked worktree copies. A plain `grep -r` hits all of them and reports
matches in files you must not edit.

`-z` / `-0` pair up to handle paths containing spaces (this repo has some, e.g.
`brew-path/Coffee Tree.html`). On macOS, `sed -i` takes a mandatory backup
suffix — `sed -i ''` means "no backup".

### Search case-insensitively when sweeping a name

```bash
git ls-files -z | xargs -0 grep -Iin "coffee.quest\|coffeequest"
```

A case-sensitive sweep for a product rename **will** miss things. The BrewPath
rename ([#41](https://github.com/maximsan/brewpath/issues/41)) shipped a
user-visible `'COFFEE QUEST'` wordmark and a `com.yourcompany.coffeequest`
bundle id because the search pattern only covered `coffee_quest`, `Coffee Quest`
and `coffeeQuest`. Wildcard the separator (`.`) and add `-i`.

---

## Issues

Full wayfinder operations — maps, child issues, blocking edges, frontier
queries — are in [`agents/issue-tracker.md`](agents/issue-tracker.md). The
everyday subset:

```bash
gh issue view 36 --repo maximsan/brewpath --json title,body,comments
gh issue create --repo maximsan/brewpath --title "…" --label ready-for-agent --body-file ./body.md
gh issue comment 36 --repo maximsan/brewpath --body-file ./comment.md
gh issue close 41 --repo maximsan/brewpath --comment "Landed in #42."
gh issue edit 36 --repo maximsan/brewpath --body "$(cat body.md)"
```

Check whether an issue is actually takeable — `blocked_by` counts **open**
blockers only:

```bash
gh api repos/maximsan/brewpath/issues/36 --jq '.issue_dependencies_summary.blocked_by'
```

### Before wiring issues as parallel, check for shared files

Native `blocked_by` edges express *logical* dependency. They say nothing about
two issues editing the same file, and that is a real collision:
[#36](https://github.com/maximsan/brewpath/issues/36) (bundle fonts) and
[#37](https://github.com/maximsan/brewpath/issues/37) (two-mood theme) were
wired as independently takeable, both blocked only by the rename. Both owned
`lib/shared/theme/app_typography.dart`. Worked concurrently in one tree, they
became inseparable — #37 resolves fonts by family-name string, which only
renders if #36's `pubspec.yaml` declaration exists — and had to land as a single
commit closing both.

Before declaring two tickets parallel, ask which files each will touch. Where
they overlap, sequence them or accept that they land together.

## Pull requests

```bash
git push -u origin my-branch          # -u sets upstream once

gh pr create --repo maximsan/brewpath --base main --head my-branch \
  --title "…" --body-file ./pr-body.md
```

**Always `--body-file`, never `--body`** for anything longer than a sentence.
Same reason as the heredoc: a file needs no shell escaping at all.

```bash
gh pr view 42 --repo maximsan/brewpath \
  --json number,state,mergeable,mergeStateStatus,changedFiles \
  --jq '"#\(.number) \(.state) \(.mergeStateStatus)"'
```

`--json … --jq` gives a parseable answer instead of a decorated page — use it to
verify a command did what you meant rather than assuming.

`mergeStateStatus` is worth knowing: `UNSTABLE` means checks are still running
or failing, not that the merge would conflict; `mergeable: MERGEABLE` is the
conflict signal.

### Checks

```bash
gh pr checks 42 --repo maximsan/brewpath              # snapshot; non-zero exit if any failed
gh pr checks 42 --repo maximsan/brewpath --watch      # blocks until all finish
gh run view <run-id> --repo maximsan/brewpath --log-failed
```

`--log-failed` prints only the failing job's log instead of the whole run —
usually the difference between reading 40 lines and 4,000.

⚠️ `main` has **no branch protection**, so nothing refuses a merge with red
checks. Check first; the discipline is manual.

Note that `pull_request` runs use the workflow file from the *merge* of head
into base. A CI fix landing on `main` therefore takes effect on open PRs as soon
as their checks re-run — no rebase needed.

### Merging

```bash
gh pr merge 42 --repo maximsan/brewpath --merge --delete-branch
```

| Flag | Result |
| --- | --- |
| `--merge` | keeps every commit, adds a merge commit |
| `--squash` | collapses the branch into one commit |
| `--rebase` | replays commits onto the base, no merge commit |

Prefer `--merge` when the branch's commits map to separate issues — the split is
information a future reader wants, and squashing a large mechanical change into
one commit makes `git bisect` less useful.

---

## Reproducing CI locally

CI is five jobs ([`13-ci-cd.md`](13-ci-cd.md)). Run them in this order before
pushing; they are the same commands the workflow uses.

```bash
flutter pub get                                    # required BEFORE format — see below

tool/check_changelog.sh                            # pull-request job; needs origin/main fetched
dart format --output=none --set-exit-if-changed lib test integration_test
flutter analyze
dart run dart_code_linter:metrics analyze lib --set-exit-on-violation-level=warning
flutter test
flutter build ios --release --no-codesign
```

Two things that are easy to get wrong:

- **`dart format .` is not the scoped command.** Unscoped, it descends into
  `build/`, where Firebase plugins copy example apps with broken includes, and
  it fails on files that are not ours. Always pass `lib test integration_test`.
- **`flutter pub get` must run first, including for the format check.**
  `dart format` selects its style from the package's language version, which it
  reads via `.dart_tool/package_config.json`. Without resolution it falls back
  to the newest language version and reformats files that are correct at this
  package's `sdk: ">=3.8.0"` floor. This exact omission kept the `format` job
  red on `main` for over a week
  ([#43](https://github.com/maximsan/brewpath/pull/43)).

`flutter analyze` does **not** cover `dart_code_linter`'s per-function metrics,
and `flutter test` does **not** run `integration_test/` — those need a device.

### The changelog job

`tool/check_changelog.sh` fails a pull request that changes `lib/`,
`assets/content/` or `pubspec.yaml` without adding an entry to
`docs/CHANGELOG.md`. Generated Dart (`*.g.dart`, `*.freezed.dart`) does not
count as a product change, and touching the changelog is not enough — the diff
has to add at least one bullet.

When the change genuinely does not belong in the changelog — a pure refactor, a
formatting pass, test-only work, regenerated output — label the PR
**`no-changelog`** and the job is skipped rather than failed. Use the label
rather than an empty entry: a changelog padded with "refactored X" is how it
stops being read.

---

## Shell notes (zsh)

The default shell here is zsh, which differs from bash in two ways that have
each caused a real mistake in this repo:

```bash
# Arrays are 1-indexed. ${arr[0]} is EMPTY, not the first element.
arr=(a b c); echo ${arr[1]}      # → a

# Unquoted variables do NOT word-split.
files="a.md b.md"
for f in $files; do ... done     # ONE iteration, "a.md b.md" — wrong
files=(a.md b.md)                # use an array
for f in "${files[@]}"; do ... done
```

Both fail *silently* in the wrong direction: the loop appears to succeed while
touching nothing. When a batch edit reports success, verify the result rather
than the exit code.
