#!/bin/bash
# Claude Code Statusline Script
# Configure by editing the SHOW_* variables below

# ─── Configuration ───────────────────────────────────────────────────────────
SHOW_USER=true
SHOW_DIR=true
SHOW_GIT_BRANCH=true
SHOW_MODEL=false
SHOW_TOKENS=false
SHOW_COST=false

# Style: "nerd" (requires nerd font), "unicode", or "ascii"
STYLE="nerd"
# ─────────────────────────────────────────────────────────────────────────────

case "$STYLE" in
    nerd)
        ICON_USER=""
        ICON_DIR=""
        ICON_GIT=""
        ICON_MODEL="󰧑"
        ICON_TOKENS="󰆼"
        ICON_COST="󰄛"
        SEP="  "
        ;;
    unicode)
        ICON_USER="⚡"
        ICON_DIR="📁"
        ICON_GIT="⎇"
        ICON_MODEL="◆"
        ICON_TOKENS="●"
        ICON_COST="$"
        SEP=" · "
        ;;
    ascii)
        ICON_USER=""
        ICON_DIR=""
        ICON_GIT=""
        ICON_MODEL=""
        ICON_TOKENS=""
        ICON_COST="$"
        SEP=" | "
        ;;
esac

input=$(cat)
dir=$(echo "$input" | jq -r '.workspace.current_dir // empty')
model=$(echo "$input" | jq -r '.model // empty')
tokens=$(echo "$input" | jq -r '.session.tokens_used // empty')
cost=$(echo "$input" | jq -r '.session.total_cost // empty')

parts=()

if $SHOW_USER; then
    [ -n "$ICON_USER" ] && parts+=("$ICON_USER $(whoami)") || parts+=("$(whoami)")
fi

if $SHOW_DIR && [ -n "$dir" ]; then
    if [ "$dir" = "$HOME" ]; then
        display="~"
    else
        display="${dir/#$HOME/\~}"
    fi
    [ -n "$ICON_DIR" ] && parts+=("$ICON_DIR $display") || parts+=("$display")
fi

if $SHOW_GIT_BRANCH && [ -n "$dir" ]; then
    branch=$(cd "$dir" 2>/dev/null && git rev-parse --abbrev-ref HEAD 2>/dev/null)
    if [ -n "$branch" ]; then
        [ -n "$ICON_GIT" ] && parts+=("$ICON_GIT $branch") || parts+=("$branch")
    fi
fi

if $SHOW_MODEL && [ -n "$model" ]; then
    short_model=$(echo "$model" | sed 's/claude-//' | cut -d'-' -f1-2)
    [ -n "$ICON_MODEL" ] && parts+=("$ICON_MODEL $short_model") || parts+=("($short_model)")
fi

if $SHOW_TOKENS && [ -n "$tokens" ]; then
    formatted=$(printf "%'d" "$tokens" 2>/dev/null || echo "$tokens")
    [ -n "$ICON_TOKENS" ] && parts+=("$ICON_TOKENS $formatted") || parts+=("${formatted}t")
fi

if $SHOW_COST && [ -n "$cost" ]; then
    [ -n "$ICON_COST" ] && parts+=("$ICON_COST$(printf '%.2f' "$cost")") || parts+=("\$$(printf '%.2f' "$cost")")
fi

output=""
for i in "${!parts[@]}"; do
    [ $i -gt 0 ] && output+="$SEP"
    output+="${parts[$i]}"
done

printf '%s' "$output"
