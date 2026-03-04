# pastemax

> Paste screenshots directly into Claude Code (and any terminal) — from any terminal, no config needed.

## The problem

Take a screenshot with `Cmd+Ctrl+Shift+4`. Try to paste it into Claude Code in your terminal. Nothing.

Claude Code expects a file, not raw image data. There's no native way to bridge this.

## How it works

pastemax runs as a lightweight background daemon. The moment you copy an image to your clipboard (screenshot, copy from browser, anywhere), it:

1. Saves the image to `/tmp/pastemax/clipboard_<timestamp>.png`
2. Enriches your clipboard with a file reference — alongside the original image data

Now when you paste into Claude Code, it receives a file. When you paste into Slack or Keynote, they still receive the image. **Both work. Nothing breaks.**

No hotkeys. No configuration. No permissions required. Zero CPU at idle.

## Install

```bash
git clone https://github.com/iajaykarthick/pastemax
cd pastemax
./install.sh
```

Requires macOS 13+ and Swift (via Xcode Command Line Tools: `xcode-select --install`).

## Usage

Just install it and forget it. It starts on login automatically.

```bash
# Take a screenshot to clipboard
Cmd+Ctrl+Shift+4

# Paste into Claude Code
cmd+v  # works
```

Works in every terminal: Ghostty, iTerm2, WezTerm, Terminal.app, all of them.

## Logs

```bash
tail -f /tmp/pastemax/pastemax.log
```

## Stop / Uninstall

```bash
# Stop
launchctl unload ~/Library/LaunchAgents/com.pastemax.daemon.plist

# Uninstall completely
./uninstall.sh
```

## Why does this work?

When you copy a file in Finder and paste into a terminal, the terminal receives a file path. pastemax exploits this by enriching clipboard image data with an equivalent file reference the moment it appears on your clipboard. The mechanism works at the OS clipboard layer, so it works in every terminal.

## Platforms

- [x] macOS
- [ ] Linux (coming — different clipboard model, `wl-paste`/`xclip`)

## Contributing

PRs welcome. Keep it small, keep it fast.

## License

MIT
