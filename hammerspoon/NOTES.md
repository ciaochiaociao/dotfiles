# Hammerspoon Notes

## macOS Automation Layers

1. **AppleScript / JXA** — app-specific scripting. Check support via Script Editor → File → Open Dictionary.
   - Rich: iTerm2, Chrome, Safari, Finder
   - Minimal/none: Firefox, Spotify, most Electron apps (VS Code, Slack)

2. **Accessibility API** — what Hammerspoon uses for window management. Works on any app without app cooperation. Can read titles, positions, click buttons, but can't access app internals (tab URLs, file contents).

3. **URL schemes** — e.g. `vscode://file/path/to/file`. Useful for launching specific views.

4. **CLI tools** — e.g. `code`, `iterm2`, `gh`. Often more capable than AppleScript.

5. **Shortcuts.app / Automator** — Apple's own automation layer with app-exposed actions.

## Current Layout Manager Design

- Positions stored as screen-relative fractions (0-1)
- Screens matched by orientation (vertical/standard/wide/ultrawide), not name or index
- AppleScript used ONLY for Chrome tab URLs and iTerm2 sessions (Hammerspoon can't access those)
- Chrome windows: always open fresh on load (avoids duplicate URL matching bugs)
- Non-Chrome windows: match and reposition existing ones
