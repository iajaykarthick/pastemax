#!/bin/bash
set -e

BINARY_NAME="pastemax"
INSTALL_PATH="/usr/local/bin/$BINARY_NAME"
PLIST_NAME="com.pastemax.daemon.plist"
LAUNCH_AGENTS_DIR="$HOME/Library/LaunchAgents"
PLIST_DEST="$LAUNCH_AGENTS_DIR/$PLIST_NAME"

echo "→ Building pastemax..."
swift build -c release 2>&1

BUILT_BINARY=".build/release/$BINARY_NAME"

echo "→ Installing binary to $INSTALL_PATH..."
sudo cp "$BUILT_BINARY" "$INSTALL_PATH"
sudo chmod +x "$INSTALL_PATH"

echo "→ Creating log directory..."
mkdir -p /tmp/pastemax

echo "→ Installing LaunchAgent..."
mkdir -p "$LAUNCH_AGENTS_DIR"
cp "$PLIST_NAME" "$PLIST_DEST"

# Unload if already running
launchctl unload "$PLIST_DEST" 2>/dev/null || true

echo "→ Starting pastemax..."
launchctl load "$PLIST_DEST"

echo ""
echo "✓ pastemax is running."
echo "  Take a screenshot (Cmd+Ctrl+Shift+4) and paste anywhere."
echo "  Logs: tail -f /tmp/pastemax/pastemax.log"
echo ""
echo "  To stop:    launchctl unload $PLIST_DEST"
echo "  To uninstall: ./uninstall.sh"
