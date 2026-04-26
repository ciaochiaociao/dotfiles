#!/bin/bash
# Install Nerd Fonts (per-user) and configure xterm via ~/.Xresources

set -e

FONT_NAME="${FONT_NAME:-JetBrainsMono}"
FONT_DIR="$HOME/.local/share/fonts"
XRES="$HOME/.Xresources"

install_nerd_font() {
    local font="$1"
    local url="https://github.com/ryanoasis/nerd-fonts/releases/latest/download/${font}.zip"

    if fc-list 2>/dev/null | grep -qi "${font} nerd"; then
        echo "${font} Nerd Font already installed. Skipping."
        return 0
    fi

    if ! command -v unzip >/dev/null 2>&1; then
        echo "Error: 'unzip' is required but not found." >&2
        return 1
    fi
    if ! command -v fc-cache >/dev/null 2>&1; then
        echo "Error: 'fc-cache' (fontconfig) is required but not found." >&2
        return 1
    fi

    mkdir -p "$FONT_DIR"
    (
        cd "$FONT_DIR"
        echo "Downloading ${font} Nerd Font..."
        if command -v curl >/dev/null 2>&1; then
            curl -fLO "$url"
        elif command -v wget >/dev/null 2>&1; then
            wget "$url"
        else
            echo "Error: need curl or wget." >&2
            exit 1
        fi
        echo "Extracting..."
        unzip -o "${font}.zip" -d "${font}" >/dev/null
        rm "${font}.zip"
    )

    echo "Refreshing font cache..."
    fc-cache -fv "$FONT_DIR" >/dev/null

    echo "${font} Nerd Font installed."
}

configure_xresources() {
    local font="$1"
    local face_name="${font} Nerd Font"

    if [ -f "$XRES" ] && grep -q "XTerm\*faceName" "$XRES"; then
        echo "XTerm faceName already configured in $XRES. Skipping."
        return 0
    fi

    cat >> "$XRES" <<EOF

! XTerm Nerd Font configuration
XTerm*faceName: ${face_name}
XTerm*faceSize: 11
XTerm*renderFont: true
XTerm*locale: true
XTerm*utf8: 1
EOF

    echo "Appended XTerm font config to $XRES"

    if command -v xrdb >/dev/null 2>&1 && [ -n "$DISPLAY" ]; then
        xrdb -merge "$XRES"
        echo "Loaded $XRES via xrdb. Relaunch xterm to apply."
    else
        echo "Run 'xrdb -merge $XRES' inside an X session to load."
    fi
}

install_nerd_font "$FONT_NAME"
configure_xresources "$FONT_NAME"
