# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

pastemax is a macOS daemon that enriches clipboard image data with file URLs, enabling pasting screenshots into Claude Code and other terminal apps. It polls `NSPasteboard` every 300ms, detects image data (PNG/TIFF), saves it to `/tmp/pastemax/`, and adds a `public.file-url` reference back to the clipboard while preserving all original items.

## Build & Run Commands

```bash
# Build release binary
swift build -c release

# Install (builds, copies to /usr/local/bin, loads LaunchAgent)
./install.sh

# Uninstall (stops daemon, removes binary and plist, cleans /tmp/pastemax)
./uninstall.sh

# View logs
tail -f /tmp/pastemax/pastemax.log
tail -f /tmp/pastemax/pastemax.error.log
```

## Architecture

Single-file Swift implementation (`main.swift`, ~122 lines) with no external dependencies.

- **`ClipboardWatcher`** class: polls `NSPasteboard.general.changeCount`, detects images, saves to `/tmp/pastemax/clipboard_<timestamp>.<ext>`, enriches clipboard with file URL
- **Recursion prevention**: skips processing when clipboard already contains `.fileURL` type, and updates internal change count after writes
- **Cleanup**: removes files older than 1 hour on startup
- **Deployment**: runs as a macOS LaunchAgent (`com.pastemax.daemon.plist`) with `RunAtLoad` and `KeepAlive`

## Key Files

- `main.swift` — entire daemon implementation
- `Package.swift` — SPM manifest (macOS 13+, Swift 5.9+)
- `com.pastemax.daemon.plist` — LaunchAgent config (binary at `/usr/local/bin/pastemax`)
- `install.sh` / `uninstall.sh` — installation scripts (require sudo)

## Platform

macOS only. Uses AppKit (`NSPasteboard`, `NSImage`) and Foundation frameworks.
