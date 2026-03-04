#!/bin/bash
set -e

PLIST_DEST="$HOME/Library/LaunchAgents/com.pastemax.daemon.plist"

echo "→ Stopping pastemax..."
launchctl unload "$PLIST_DEST" 2>/dev/null || true

echo "→ Removing LaunchAgent..."
rm -f "$PLIST_DEST"

echo "→ Removing binary..."
sudo rm -f /usr/local/bin/pastemax

echo "→ Cleaning up tmp files..."
rm -rf /tmp/pastemax

echo "✓ pastemax uninstalled."
