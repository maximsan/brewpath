#!/bin/sh
# Claude Code PostToolUse hook (Write|Edit): formats the Dart file just written.
# Exit 2 hands dart's error back to the agent, which is what a parse failure
# in a file it just wrote deserves.
input=$(cat)
if command -v jq >/dev/null 2>&1; then
  path=$(printf '%s' "$input" | jq -r '.tool_input.file_path // empty')
else
  path=$(printf '%s' "$input" | python3 -c 'import json,sys; print(json.load(sys.stdin).get("tool_input", {}).get("file_path", ""))')
fi
case "$path" in
  *.dart) [ -f "$path" ] && { dart format "$path" >/dev/null || exit 2; } ;;
esac
exit 0
