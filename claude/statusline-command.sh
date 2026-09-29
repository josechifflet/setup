#!/usr/bin/env bash
# Claude Code Status Line
# Format: profile | dir | branch | model effort | used/total tokens | +lines/-lines | age

# The config dir name, read at runtime so one file serves every profile that
# CLAUDE_CONFIG_DIR selects.
PROFILE="$(basename "${CLAUDE_CONFIG_DIR:-$HOME/.claude}")"
PROFILE="${PROFILE#.}"

set -euo pipefail

input=$(cat)

# Extract values in one jq call. The statusline runs often, so avoid
# repeated parser startup for each field.
# effort stays last: IFS collapses a run of tabs, so an empty field
# anywhere but the end would shift every value after it.
IFS=$'	' read -r cwd model ctx_size lines_added lines_removed input_tokens cache_create cache_read duration_ms effort < <(
  jq -r '
    [
      (.cwd // ""),
      (.model.display_name // .model.name // "claude"),
      (.context_window.context_window_size // 0),
      (.cost.total_lines_added // 0),
      (.cost.total_lines_removed // 0),
      (.context_window.current_usage.input_tokens // 0),
      (.context_window.current_usage.cache_creation_input_tokens // 0),
      (.context_window.current_usage.cache_read_input_tokens // 0),
      ((.cost.total_duration_ms // 0) | floor),
      (.effort.level // "")
    ] | @tsv
  ' <<< "$input"
)

# Colors are real escape bytes and the line prints with %s. Folder, branch and
# model names come from repos and payloads, so %b would turn a backslash
# sequence in them into a live terminal escape (clipboard writes via OSC 52).
RED=$'\033[31m'
YELLOW=$'\033[33m'
GREEN=$'\033[32m'
CYAN=$'\033[36m'
DIM=$'\033[2m'
RESET=$'\033[0m'

# Raw control bytes in those names would reach the terminal all the same.
strip_ctrl() { printf '%s' "${1//[[:cntrl:]]/}"; }

# Directory (basename, ~ for home)
dir=""
if [[ -n "$cwd" ]]; then
  dir="${cwd/#$HOME/\~}"
  dir=$(basename "$dir")
fi

# Git branch
branch=""
if [[ -n "$cwd" ]] && git -C "$cwd" rev-parse --git-dir &> /dev/null; then
  branch=$(git -C "$cwd" symbolic-ref --short HEAD 2> /dev/null || echo "detached")
fi

# Model shortname
model_short=""
case "$model" in
  *[Oo]pus*) model_short="opus" ;;
  *[Ss]onnet*) model_short="sonnet" ;;
  *[Hh]aiku*) model_short="haiku" ;;
  *[Ff]able*) model_short="fable" ;;
  *) model_short="${model:0:8}" ;;
esac

# Reasoning effort level — dimmed suffix on the model (absent when the
# selected model has no effort parameter, so the segment stays clean).
effort=$(strip_ctrl "$effort")
effort_display=""
[[ -n "$effort" ]] && effort_display=" ${DIM}$effort${RESET}"

# Format token count as human-readable (e.g. 45.2k, 1.0M)
fmt_tokens() {
  local n=$1
  local whole tenths

  if ((n >= 1000000)); then
    whole=$((n / 1000000))
    tenths=$(((n % 1000000) / 100000))
    printf "%d.%dM" "$whole" "$tenths"
  elif ((n >= 1000)); then
    whole=$((n / 1000))
    tenths=$(((n % 1000) / 100))
    printf "%d.%dk" "$whole" "$tenths"
  else
    printf "%d" "$n"
  fi
}

# Context tokens — used_tokens is the input-only sum that matches used_percentage
used_tokens=$((input_tokens + cache_create + cache_read))
# The JSON's context_window_size always reports the model's native window (1M),
# even when CLAUDE_CODE_AUTO_COMPACT_WINDOW lowers the effective ceiling — use
# the override as /max so the display matches where auto-compact actually fires.
ctx_max=$ctx_size
if [[ "${CLAUDE_CODE_AUTO_COMPACT_WINDOW:-}" =~ ^[0-9]+$ ]] &&
  ((CLAUDE_CODE_AUTO_COMPACT_WINDOW > 0 && CLAUDE_CODE_AUTO_COMPACT_WINDOW < ctx_size)); then
  ctx_max=$CLAUDE_CODE_AUTO_COMPACT_WINDOW
fi
ctx_display=""
if ((ctx_max > 0)); then
  pct_int=$((used_tokens * 100 / ctx_max))
  # Color based on usage percentage
  if ((pct_int >= 80)); then
    ctx_color="$RED"
  elif ((pct_int >= 50)); then
    ctx_color="$YELLOW"
  else
    ctx_color="$GREEN"
  fi
  ctx_display="${ctx_color}$(fmt_tokens "$used_tokens")${RESET}${DIM}/${RESET}$(fmt_tokens "$ctx_max")"
fi

# Lines changed
lines_display=""
if [[ "$lines_added" != "0" || "$lines_removed" != "0" ]]; then
  lines_display="${GREEN}+${lines_added}${RESET}/${RED}-${lines_removed}${RESET}"
fi

# Session age. Long unattended runs are the failure this setup guards
# against, so the segment turns yellow past one hour and red past three.
age_display=""
if ((duration_ms >= 60000)); then
  mins=$((duration_ms / 60000))
  if ((mins >= 180)); then
    age_color="$RED"
  elif ((mins >= 60)); then
    age_color="$YELLOW"
  else
    age_color="$DIM"
  fi
  if ((mins >= 60)); then
    age_display="${age_color}$((mins / 60))h$(printf '%02d' $((mins % 60)))m${RESET}"
  else
    age_display="${age_color}${mins}m${RESET}"
  fi
fi

# Build output — profile tag first so you always know which config dir is active
PROFILE=$(strip_ctrl "$PROFILE")
dir=$(strip_ctrl "$dir")
branch=$(strip_ctrl "$branch")
model_short=$(strip_ctrl "$model_short")
MAGENTA=$'\033[35m'
out="${MAGENTA}${PROFILE}${RESET}"
[[ -n "$dir" ]] && out="$out ${DIM}|${RESET} $dir"
[[ -n "$branch" ]] && out="$out ${DIM}|${RESET} $branch"
[[ -n "$model_short" ]] && out="$out ${DIM}|${RESET} ${CYAN}$model_short${RESET}$effort_display"
[[ -n "$ctx_display" ]] && out="$out ${DIM}|${RESET} $ctx_display"
[[ -n "$lines_display" ]] && out="$out ${DIM}|${RESET} $lines_display"
[[ -n "$age_display" ]] && out="$out ${DIM}|${RESET} $age_display"

printf '%s' "$out"
