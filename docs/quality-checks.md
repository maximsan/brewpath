# Quality checks — what runs before code leaves the machine

The repo's own rules run at four moments, earliest first. `flutter analyze`
and the full suite stay in CI, which runs them on every push; the iOS build
and the smoke suite run on Codemagic, on `main` and nightly respectively
([`ci-cd.md`](ci-cd.md)).

## The four moments

| When | What runs |
| --- | --- |
| Claude Code writes a Dart file | `dart format` on that file, then the comment cap on it (`.claude/settings.json`, `PostToolUse`); a failure goes straight back to the agent |
| `git commit` | `dart format --set-exit-if-changed` and the comment cap on the staged Dart files (sub-second) |
| `git push` | the format check, the `dart_code_linter` metrics, every `*_guard_test.dart`, the comment cap on every Dart file changed against the base, and `tool/check_changelog.sh` (about half a minute) |
| CI, on a pull request | the same as push, as steps of the one `checks` job, plus `flutter analyze` and `flutter test` ([`ci-cd.md`](ci-cd.md)) — the iOS build is not among them, and runs on `main` |

## The comment cap

`tool/check_comments.dart` enforces the _Comments_ convention in
[`CLAUDE.md`](../CLAUDE.md). The changed-files form diffs against your local
`origin/main`, so `git fetch` first. To see what is left across the whole
tree:

```bash
find lib test integration_test -name '*.dart' | xargs dart tool/check_comments.dart
```

## The hooks

They live in `tool/git-hooks/`; `tool/install_hooks.sh` links them into the
repository's shared hooks directory, so every worktree runs them and a
machine-wide `commit-msg` hook is left alone. Run it once per clone; Claude
Code runs it at session start.

Escapes, each for one situation:

- `git push --no-verify` skips the whole pre-push.
- `NO_CHANGELOG=1 git push` skips only the changelog check, for a PR that will
  carry the `no-changelog` label — what counts as a product change is in
  [`git-and-github-workflow.md`](git-and-github-workflow.md), _The changelog job_.
- `BASE_REF=origin/<branch> git push` names the base of a branch stacked on
  another, which is what CI compares against too.

## When a check fails

- **On write** — the failure is handed back to the agent, which fixes the
  file before moving on; nothing for you to do.
- **On commit** — the hook names the file. Run `dart format` on it, or cut the
  comment block to six lines, and commit again.
- **On push** — the hook names the check. The commands it ran, in the order it
  ran them, are in [`git-and-github-workflow.md`](git-and-github-workflow.md),
  _Reproducing CI locally_; fix, commit, push again. A missing changelog bullet
  is either written or the PR is labelled `no-changelog`.
- **In CI** — `gh run view <run-id> --log-failed` prints only the failing
  job's log ([`git-and-github-workflow.md`](git-and-github-workflow.md), _Checks_).
