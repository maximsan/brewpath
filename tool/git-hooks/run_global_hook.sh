#!/bin/sh
# Sourced by every hook here. Pointing core.hooksPath at this directory would
# otherwise switch off a machine-wide hook of the same name, so run that first.
# A hook that has already read its stdin passes it on through HOOK_STDIN.
hook_name=$(basename "$0")
global_dir=$(git config --global --type=path --get core.hooksPath || true)
if [ -n "$global_dir" ] && [ -x "$global_dir/$hook_name" ]; then
  if [ -n "${HOOK_STDIN:-}" ]; then
    printf '%s\n' "$HOOK_STDIN" | "$global_dir/$hook_name" "$@" || exit $?
  elif [ -n "${HOOK_STDIN+set}" ]; then
    "$global_dir/$hook_name" "$@" </dev/null || exit $?
  else
    "$global_dir/$hook_name" "$@" || exit $?
  fi
fi
