#!/usr/bin/env bash
# tmux.sh — manage the forge-<task-id> tmux window
#
# Usage:
#   tmux.sh spawn <task-id> <worktree-path>   # creates the window, prints "session:window"
#   tmux.sh kill  <task-id>
#   tmux.sh list
#
# Layout: one window named forge-<task-id> inside session "forge",
# with left pane (70%) running `claude` and right pane (30%) running
# `./setup.sh && ./run.sh` from the worktree directory.
#
# State: ~/.forge/sessions.json
# Requires: jq, tmux.

set -euo pipefail

STATE_DIR="${FORGE_HOME:-$HOME/.forge}"
SESS_FILE="$STATE_DIR/sessions.json"

mkdir -p "$STATE_DIR"
[ -f "$SESS_FILE" ] || echo '{}' > "$SESS_FILE"

cmd="${1:-}"
task="${2:-}"

SESSION="forge"

write_atomic() {
  local tmp
  tmp=$(mktemp "${SESS_FILE}.XXXXXX")
  cat > "$tmp"
  mv "$tmp" "$SESS_FILE"
}

case "$cmd" in
  spawn)
    path="${3:-}"
    [ -n "$task" ] && [ -n "$path" ] || { echo "usage: $0 spawn <task-id> <worktree-path>" >&2; exit 2; }

    window="forge-$task"
    target="$SESSION:$window"

    if ! tmux has-session -t "$SESSION" 2>/dev/null; then
      tmux new-session -d -s "$SESSION" -n "$window" -c "$path"
    elif ! tmux list-windows -t "$SESSION" -F '#{window_name}' | grep -qx "$window"; then
      tmux new-window -t "$SESSION" -n "$window" -c "$path"
    fi

    # Left pane: claude
    tmux send-keys -t "$target.0" "claude" C-m

    # Right pane (30%): setup + run
    if [ "$(tmux list-panes -t "$target" | wc -l)" -lt 2 ]; then
      tmux split-window -h -p 30 -t "$target" -c "$path"
    fi
    tmux send-keys -t "$target.1" "./setup.sh && ./run.sh" C-m

    jq --arg t "$task" --arg w "$target" '. + {($t): $w}' "$SESS_FILE" | write_atomic

    echo "$target"
    ;;

  kill)
    [ -n "$task" ] || { echo "missing task id" >&2; exit 2; }
    target=$(jq -r --arg t "$task" '.[$t] // empty' "$SESS_FILE")
    if [ -n "$target" ]; then
      tmux kill-window -t "$target" 2>/dev/null || true
    fi
    jq --arg t "$task" 'del(.[$t])' "$SESS_FILE" | write_atomic
    ;;

  list)
    cat "$SESS_FILE"
    ;;

  *)
    echo "usage: $0 {spawn|kill|list} ..." >&2
    exit 2
    ;;
esac
