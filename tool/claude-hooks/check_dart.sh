#!/bin/sh
# Claude Code PostToolUse hook (Write|Edit): formats the Dart file just written
# and checks its comment blocks against the cap. Exit 2 hands the message back
# to the agent, so it fixes the file before anything is committed. Without a
# Dart SDK in reach it steps aside; the git hooks and CI still enforce both.
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

dart_bin=$(command -v dart || true)
for candidate in /opt/homebrew/bin/dart /usr/local/bin/dart "${FLUTTER_ROOT:-}/bin/dart"; do
  [ -n "$dart_bin" ] && break
  [ -x "$candidate" ] && dart_bin=$candidate
done
[ -n "$dart_bin" ] || exit 0

root=${CLAUDE_PROJECT_DIR:-$(cd "$(dirname "$0")/../.." && pwd)}
"$dart_bin" format "$path" >/dev/null || exit 2
"$dart_bin" "$root/tool/check_comments.dart" "$path" || exit 2
exit 0
