#!/usr/bin/env bash
# ports.sh — allocate/release ports in ~/.forge/ports.json
#
# Usage:
#   ports.sh allocate <task-id>   # prints the allocated port, idempotent
#   ports.sh release  <task-id>
#   ports.sh list
#
# Reads port_range from ~/.forge/config.json (defaults to [3000, 3999]).
# Requires: jq.

set -euo pipefail

STATE_DIR="${FORGE_HOME:-$HOME/.forge}"
PORTS_FILE="$STATE_DIR/ports.json"
CONFIG_FILE="$STATE_DIR/config.json"

mkdir -p "$STATE_DIR"
[ -f "$PORTS_FILE" ] || echo '{}' > "$PORTS_FILE"

range_lo=3000
range_hi=3999
if [ -f "$CONFIG_FILE" ]; then
  range_lo=$(jq -r '.port_range[0] // 3000' "$CONFIG_FILE")
  range_hi=$(jq -r '.port_range[1] // 3999' "$CONFIG_FILE")
fi

cmd="${1:-}"
task="${2:-}"

write_atomic() {
  local tmp
  tmp=$(mktemp "${PORTS_FILE}.XXXXXX")
  cat > "$tmp"
  mv "$tmp" "$PORTS_FILE"
}

case "$cmd" in
  allocate)
    [ -n "$task" ] || { echo "missing task id" >&2; exit 2; }

    existing=$(jq -r --arg t "$task" '.[$t] // empty' "$PORTS_FILE")
    if [ -n "$existing" ]; then
      echo "$existing"
      exit 0
    fi

    used=$(jq -r 'to_entries | map(.value) | .[]' "$PORTS_FILE")
    for p in $(seq "$range_lo" "$range_hi"); do
      if ! printf '%s\n' "$used" | grep -qx "$p"; then
        jq --arg t "$task" --argjson p "$p" '. + {($t): $p}' "$PORTS_FILE" | write_atomic
        echo "$p"
        exit 0
      fi
    done

    echo "port range exhausted ($range_lo-$range_hi)" >&2
    exit 1
    ;;

  release)
    [ -n "$task" ] || { echo "missing task id" >&2; exit 2; }
    jq --arg t "$task" 'del(.[$t])' "$PORTS_FILE" | write_atomic
    ;;

  list)
    cat "$PORTS_FILE"
    ;;

  *)
    echo "usage: $0 {allocate|release|list} [task-id]" >&2
    exit 2
    ;;
esac
