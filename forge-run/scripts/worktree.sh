#!/usr/bin/env bash
# worktree.sh — manage git worktrees for Forge tasks
#
# Usage:
#   worktree.sh create <task-id> <branch>   # creates .worktrees/<task-id>, prints path
#   worktree.sh remove <task-id>
#   worktree.sh path   <task-id>            # prints path (empty if none)
#   worktree.sh list
#
# State: ~/.forge/worktrees.json
# Requires: jq, git.

set -euo pipefail

STATE_DIR="${FORGE_HOME:-$HOME/.forge}"
WT_FILE="$STATE_DIR/worktrees.json"

mkdir -p "$STATE_DIR"
[ -f "$WT_FILE" ] || echo '{}' > "$WT_FILE"

cmd="${1:-}"
task="${2:-}"

write_atomic() {
  local tmp
  tmp=$(mktemp "${WT_FILE}.XXXXXX")
  cat > "$tmp"
  mv "$tmp" "$WT_FILE"
}

case "$cmd" in
  create)
    branch="${3:-}"
    [ -n "$task" ] && [ -n "$branch" ] || { echo "usage: $0 create <task-id> <branch>" >&2; exit 2; }

    repo_root=$(git rev-parse --show-toplevel)
    path="$repo_root/.worktrees/$task"

    if [ ! -d "$path" ]; then
      # Base the new branch on origin/main if available, else current HEAD.
      base="HEAD"
      if git -C "$repo_root" show-ref --verify --quiet refs/remotes/origin/main; then
        base="origin/main"
      fi
      git -C "$repo_root" worktree add "$path" -b "$branch" "$base"
    fi

    jq --arg t "$task" --arg p "$path" --arg b "$branch" \
      '. + {($t): {path: $p, branch: $b}}' "$WT_FILE" | write_atomic

    echo "$path"
    ;;

  remove)
    [ -n "$task" ] || { echo "missing task id" >&2; exit 2; }
    path=$(jq -r --arg t "$task" '.[$t].path // empty' "$WT_FILE")
    if [ -n "$path" ] && [ -d "$path" ]; then
      git worktree remove --force "$path" 2>/dev/null || rm -rf "$path"
    fi
    jq --arg t "$task" 'del(.[$t])' "$WT_FILE" | write_atomic
    ;;

  path)
    [ -n "$task" ] || { echo "missing task id" >&2; exit 2; }
    jq -r --arg t "$task" '.[$t].path // empty' "$WT_FILE"
    ;;

  list)
    cat "$WT_FILE"
    ;;

  *)
    echo "usage: $0 {create|remove|path|list} ..." >&2
    exit 2
    ;;
esac
