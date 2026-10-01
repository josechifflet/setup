#!/usr/bin/env bash
set -euo pipefail

# SessionStart, every source: name this session's ID, then point at the plans
# under ~/.local/state/plans whose `Session:` line holds it, newest first, so
# a plan survives compaction and resume. A pointer, not the plan: a plan can
# outgrow the 10,000-character cap on hook output, and its Rules line already
# says to reread it. Ownership lives in the file, not its name, so a plan handed
# to another session moves with it. The one instruction the output carries
# matters only when a plan exists, so it rides here instead of CLAUDE.md.

{ payload=$(< /dev/stdin); } 2> /dev/null || payload=$(cat)
id=$(sed -n 's/.*"session_id" *: *"\([^"]*\)".*/\1/p' <<< "$payload")
[[ -n $id ]] || exit 0
echo "Session ID: $id"

shopt -s nullglob
plans=("$HOME"/.local/state/plans/*/*.md)
((${#plans[@]})) || exit 0

owned=""
while IFS= read -r plan; do
  grep -qxF "Session: $id" "$plan" || continue
  owned+="- $plan — $(grep -m1 '^Next:' "$plan" || echo 'Next: missing')"$'\n'
done < <(ls -t -- "${plans[@]}")

if [[ -n $owned ]]; then
  printf 'Plans this session owns, newest first. Work the one the user names, else the first; reread it before you continue:\n%s' "$owned"
fi
