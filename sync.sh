#!/bin/bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
HOSTS_FILE="$SCRIPT_DIR/sync_hosts.conf"
REMOTE_DIR="~/dotfiles"

# ── Colors ───────────────────────────────────────────────────────────────
red()   { printf "\033[31m%s\033[0m" "$1"; }
green() { printf "\033[32m%s\033[0m" "$1"; }
dim()   { printf "\033[90m%s\033[0m" "$1"; }

# ── Read hosts ───────────────────────────────────────────────────────────
if [[ ! -f "$HOSTS_FILE" ]]; then
    echo "$(red "Error:") $HOSTS_FILE not found"
    exit 1
fi

HOSTS=()
while IFS= read -r line; do
    HOSTS+=("$line")
done < <(grep -v '^\s*#' "$HOSTS_FILE" | grep -v '^\s*$')

if [[ ${#HOSTS[@]} -eq 0 ]]; then
    echo "$(red "Error:") No hosts defined in $HOSTS_FILE"
    exit 1
fi

echo "Syncing dotfiles to ${#HOSTS[@]} host(s)..."
echo

# ── Push local changes ───────────────────────────────────────────────────
echo "── Push local commits ──"
cd "$SCRIPT_DIR"
if git diff --quiet && git diff --cached --quiet; then
    echo "  $(dim "Working tree clean")"
else
    echo "  $(red "Warning:") uncommitted changes (only committed work will sync)"
fi

if git push 2>&1 | sed 's/^/  /'; then
    echo "  $(green "Pushed")"
else
    echo "  $(red "Push failed") -- aborting"
    exit 1
fi
echo

# ── Pull on each remote ─────────────────────────────────────────────────
echo "── Pull on remotes ──"
failed=()
for host in "${HOSTS[@]}"; do
    printf "  %-30s " "$host"
    if output=$(ssh -A -o ConnectTimeout=10 "$host" \
        "cd $REMOTE_DIR && git pull --ff-only" 2>&1); then
        if echo "$output" | grep -q "Already up to date"; then
            echo "$(dim "up to date")"
        else
            echo "$(green "pulled")"
        fi
    else
        echo "$(red "FAILED")"
        echo "$output" | sed 's/^/    /'
        failed+=("$host")
    fi
done

# ── Summary ──────────────────────────────────────────────────────────────
echo
if [[ ${#failed[@]} -eq 0 ]]; then
    echo "$(green "All ${#HOSTS[@]} host(s) synced.")"
else
    echo "$(red "${#failed[@]} host(s) failed:") ${failed[*]}"
    exit 1
fi
