#!/bin/sh
# Sourced by every hook here. Pointing core.hooksPath at this directory would
# otherwise switch off a machine-wide hook of the same name, so run that first.
hook_name=$(basename "$0")
global_dir=$(git config --global --get core.hooksPath || true)
if [ -n "$global_dir" ] && [ -x "$global_dir/$hook_name" ]; then
  "$global_dir/$hook_name" "$@" || exit $?
fi
