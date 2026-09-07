#!/bin/sh
# Claude Code PostToolUse hook (Write|Edit): formats the Dart file just written
# and checks its comment blocks against the cap. Exit 2 hands the message back
# to the agent, so it fixes the file before anything is committed.
input=$(cat)
if command -v jq >/dev/null 2>&1; then
  path=$(printf '%s' "$input" | jq -r '.tool_input.file_path // empty')
else
  path=$(printf '%s' "$input" | python3 -c 'import json,sys; print(json.load(sys.stdin).get("tool_input", {}).get("file_path", ""))')
fi
case "$path" in
  *.dart) ;;
  *) exit 0 ;;
esac
[ -f "$path" ] || exit 0
dart format "$path" >/dev/null || exit 2
dart "$CLAUDE_PROJECT_DIR/tool/check_comments.dart" "$path" || exit 2
exit 0
