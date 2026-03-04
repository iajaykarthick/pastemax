import AppKit
import Foundation

// MARK: - PasteMax Daemon
// Watches NSPasteboard for image data.
// When detected, saves to /tmp and enriches clipboard with
// public.file-url so any app (Claude Code, terminal, Finder) can paste it.
// Original image data is preserved so Slack, Keynote, Figma still work.

final class ClipboardWatcher {
    private let pasteboard = NSPasteboard.general
    private var lastChangeCount: Int = -1
    private var timer: Timer?
    private let tmpDir: URL
    init() {
        tmpDir = URL(fileURLWithPath: "/tmp/pastemax", isDirectory: true)
        try? FileManager.default.createDirectory(at: tmpDir, withIntermediateDirectories: true)
    }

    func start() {
        lastChangeCount = pasteboard.changeCount
        timer = Timer.scheduledTimer(withTimeInterval: 0.3, repeats: true) { [weak self] _ in
            self?.poll()
        }
        RunLoop.main.run()
    }

    private func poll() {
        let currentCount = pasteboard.changeCount
        guard currentCount != lastChangeCount else { return }
        lastChangeCount = currentCount

        // Check if clipboard contains image data but NOT already a file URL
        // (avoids re-processing our own writes)
        let types = pasteboard.types ?? []
        let hasImage = types.contains(.tiff) || types.contains(.png)
        let hasFileURL = types.contains(.fileURL)

        guard hasImage, !hasFileURL else { return }

        enrichClipboard()
    }

    private func enrichClipboard() {
        // Get image data - prefer PNG, fallback to TIFF
        guard let imageData = pasteboard.data(forType: .png)
                ?? pasteboard.data(forType: .tiff) else { return }

        // Determine format based on which type matched
        let isPNG = pasteboard.types?.contains(.png) == true
        let ext = isPNG ? "png" : "tiff"

        // Save to /tmp/pastemax/clipboard_<timestamp>.<ext>
        let timestamp = Int(Date().timeIntervalSince1970 * 1000)
        let fileURL = tmpDir.appendingPathComponent("clipboard_\(timestamp).\(ext)")

        do {
            try imageData.write(to: fileURL)
        } catch {
            fputs("pastemax: failed to write tmp file: \(error)\n", stderr)
            return
        }

        // Snapshot all existing clipboard items to preserve them
        let existingItems = pasteboard.pasteboardItems ?? []
        var preservedItems: [(type: NSPasteboard.PasteboardType, data: Data)] = []
        for item in existingItems {
            for type in item.types {
                if let data = item.data(forType: type) {
                    preservedItems.append((type: type, data: data))
                }
            }
        }

        // Write back: all original types + file URL
        pasteboard.clearContents()

        let newItem = NSPasteboardItem()

        // Restore original types
        for entry in preservedItems {
            newItem.setData(entry.data, forType: entry.type)
        }

        // Add file URL — this is what makes it paste like a Finder file copy
        newItem.setString(fileURL.absoluteString, forType: .fileURL)

        pasteboard.writeObjects([newItem])

        // Update changeCount so we don't re-process our own write
        lastChangeCount = pasteboard.changeCount

        // Log to stdout (visible via launchctl / Console.app)
        print("pastemax: enriched clipboard → \(fileURL.path)")
    }
}

// MARK: - Cleanup old tmp files on startup (older than 1 hour)
func cleanupOldFiles() {
    let tmpDir = URL(fileURLWithPath: "/tmp/pastemax", isDirectory: true)
    guard let files = try? FileManager.default.contentsOfDirectory(
        at: tmpDir,
        includingPropertiesForKeys: [.creationDateKey]
    ) else { return }

    let cutoff = Date().addingTimeInterval(-3600)
    for file in files {
        if let created = try? file.resourceValues(forKeys: [.creationDateKey]).creationDate,
           created < cutoff {
            try? FileManager.default.removeItem(at: file)
        }
    }
}

// MARK: - Entry point
cleanupOldFiles()
let watcher = ClipboardWatcher()
watcher.start()
