#!/bin/sh
# Links pre-commit and pre-push into the repository's shared hooks directory,
# so every worktree runs them and a machine-wide commit-msg hook stays as it
# is. Idempotent. Claude Code runs it at session start (.claude/settings.json);
# run it by hand once per clone otherwise.
set -eu
cd "$(git rev-parse --show-toplevel)"
hooks_dir="$(git rev-parse --git-common-dir)/hooks"
mkdir -p "$hooks_dir"

for hook in pre-commit pre-push; do
  link="$hooks_dir/$hook"
  if [ -e "$link" ] && [ ! -L "$link" ]; then
    echo "install_hooks: $link exists and is not a link; leaving it alone" >&2
    continue
  fi
  ln -sfn "../../tool/git-hooks/$hook" "$link"
done
