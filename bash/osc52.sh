#!/usr/bin/env bash
# Cross-platform OSC-52 clipboard bridge for tmux/vim over SSH
# Works on macOS (iTerm2, Kitty, WezTerm) and Linux terminals that support OSC-52

# Read stdin (the text to copy)
buf=$(cat)

# Safety: ignore if empty
[ -z "$buf" ] && exit 0

# Base64-encode and strip newlines
b64=$(printf "%s" "$buf" | base64 | tr -d '\r\n')

# If we're inside tmux, send the escape sequence wrapped for passthrough
if [ -n "$TMUX" ]; then
  printf "\ePtmux;\e\e]52;c;%s\a\e\\" "$b64"
  # ESC P tmux; ESC ESC ]52;c;<base64 data> BEL ESC \
  # tmux itself consumes the outer ESC P ... ESC \ sequence.
  # tmux then forwards the inner OSC-52 (ESC ]52;... BEL) to the terminal emulator.
  # The terminal (iTerm2, Kitty, WezTerm, etc.) interprets that and updates your system clipboard.
else
  # Directly emit OSC-52 sequence
  printf "\e]52;c;%s\a" "$b64"
fi
# for debugging
# printf "%s\n" "$b64"
