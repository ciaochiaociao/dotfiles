#!/bin/bash

# Read JSON input from stdin
input=$(cat)

# Extract values
model=$(echo "$input" | jq -r '.model.display_name')
model_id=$(echo "$input" | jq -r '.model.id // empty')

# Sandbox status (from env var propagated by Claude Code; not in JSON input)
if [ "${SANDBOX_RUNTIME:-}" = "1" ]; then
    sandbox="🛡 sandbox on"
else
    sandbox="🛡 sandbox off"
fi
session_name=$(echo "$input" | jq -r '.session_name // empty')
workdir=$(echo "$input" | jq -r '.workspace.current_dir')
vim_mode=$(echo "$input" | jq -r '.vim.mode // empty')
used_pct=$(echo "$input" | jq -r '.context_window.used_percentage // empty')
cost_str=$(echo "$input" | jq -r '.cost.total_cost_usd // empty')
[ -n "$cost_str" ] && cost_str=$(printf "\$%.4f" "$cost_str")

# Create progress bar for context usage
progress_bar=""
if [ -n "$used_pct" ]; then
    # Convert percentage to integer (0-100)
    used_int=$(printf "%.0f" "$used_pct")
    
    # Calculate bar segments (20 characters wide)
    filled=$((used_int / 5))
    empty=$((20 - filled))
    
    # Build progress bar
    bar=""
    for ((i=0; i<filled; i++)); do bar="${bar}█"; done
    for ((i=0; i<empty; i++)); do bar="${bar}░"; done
    
    progress_bar=$(printf "[%s] %d%%" "$bar" "$used_int")
fi

# Build output parts
parts=()

# Model name + ID (temporary)
[ -n "$model" ] && parts+=("$model ($model_id)")

# Sandbox status
parts+=("$sandbox")

# Context progress bar
[ -n "$progress_bar" ] && parts+=("$progress_bar")

# Vim mode
[ -n "$vim_mode" ] && parts+=("[$vim_mode]")

# Session name
[ -n "$session_name" ] && parts+=("[$session_name]")

# Working directory
[ -n "$workdir" ] && parts+=("$workdir")

# Cost
[ -n "$cost_str" ] && parts+=("$cost_str")

# Join parts with separator
output=""
for i in "${!parts[@]}"; do
    if [ $i -eq 0 ]; then
        output="${parts[$i]}"
    else
        output="$output | ${parts[$i]}"
    fi
done

echo "$output"
