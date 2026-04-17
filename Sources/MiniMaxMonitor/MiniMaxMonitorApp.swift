import SwiftUI

extension Notification.Name {
    static let settingsDidChange = Notification.Name("settingsDidChange")
}

@main
struct MiniMaxMonitorApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    var body: some Scene {
        Settings {
            EmptyView()
        }
    }
}

class AppDelegate: NSObject, NSApplicationDelegate {
    var statusItem: NSStatusItem?
    var popover: NSPopover?
    var timer: Timer?
    @AppStorage("apiKey") var apiKey: String = ""
    @AppStorage("refreshInterval") var refreshInterval: Int = 60

    func applicationDidFinishLaunching(_ notification: Notification) {
        setupStatusItem()
        setupPopover()
        startTimer()

        // Fix #4 & #10: respond to settings changes to restart timer and refresh
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(onSettingsDidChange),
            name: .settingsDidChange,
            object: nil
        )

        if !apiKey.isEmpty {
            Task {
                await UsageManager.shared.fetchUsage()
                updateStatusBarIcon()
            }
        }
    }

    // Fix #4: restart timer with new interval when settings change
    @objc func onSettingsDidChange() {
        startTimer()
        Task { @MainActor in
            await UsageManager.shared.fetchUsage()
            updateStatusBarIcon()
        }
    }

    func setupStatusItem() {
        statusItem = NSStatusBar.system.statusItem(withLength: 56)

        if let button = statusItem?.button {
            Task { @MainActor in
                updateStatusBarIcon()
            }
            button.action = #selector(togglePopover)
            button.target = self
        }
    }

    @MainActor
    func updateStatusBarIcon() {
        guard let button = statusItem?.button else { return }

        let percentage = UsageManager.shared.textModelPercentage
        button.image = createRingImage(percentage: percentage)
    }

    func createRingImage(percentage: Double) -> NSImage {
        let size = NSSize(width: 52, height: 22)
        let image = NSImage(size: size)

        image.lockFocus()

        let pillW: CGFloat = 48
        let pillH: CGFloat = 14
        let pillX: CGFloat = (size.width - pillW) / 2
        let pillY: CGFloat = (size.height - pillH) / 2
        let corner: CGFloat = pillH / 2

        let color: NSColor
        if percentage < 20 {
            color = NSColor(red: 0.9, green: 0.2, blue: 0.2, alpha: 1.0)
        } else if percentage < 50 {
            color = NSColor(red: 1.0, green: 0.6, blue: 0.0, alpha: 1.0)
        } else {
            color = NSColor(red: 0.2, green: 0.7, blue: 0.3, alpha: 1.0)
        }

        let pillRect = NSRect(x: pillX, y: pillY, width: pillW, height: pillH)
        let pillPath = NSBezierPath(roundedRect: pillRect, xRadius: corner, yRadius: corner)

        // 背景（淡色填充）
        color.withAlphaComponent(0.12).setFill()
        pillPath.fill()

        // 余量进度填充（裁剪到胶囊形状内）
        NSGraphicsContext.current?.saveGraphicsState()
        pillPath.setClip()
        let fillW = pillW * CGFloat(percentage / 100)
        if fillW > 0 {
            let fillRect = NSRect(x: pillX, y: pillY, width: fillW, height: pillH)
            color.withAlphaComponent(0.75).setFill()
            NSBezierPath(rect: fillRect).fill()
        }
        NSGraphicsContext.current?.restoreGraphicsState()

        // 边框
        color.withAlphaComponent(0.5).setStroke()
        pillPath.lineWidth = 1
        pillPath.stroke()

        // "token" 文字，颜色根据填充比例自适应
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = .center
        let textColor: NSColor = percentage > 55 ? .white.withAlphaComponent(0.95) : color
        let attrs: [NSAttributedString.Key: Any] = [
            .font: NSFont.systemFont(ofSize: 8, weight: .bold),
            .foregroundColor: textColor,
            .paragraphStyle: paragraphStyle
        ]

        let text = "token"
        let textSz = text.size(withAttributes: attrs)
        let textRect = NSRect(
            x: size.width / 2 - textSz.width / 2,
            y: size.height / 2 - textSz.height / 2 + 1,
            width: textSz.width,
            height: textSz.height
        )
        text.draw(in: textRect, withAttributes: attrs)

        image.unlockFocus()
        return image
    }

    func setupPopover() {
        popover = NSPopover()
        popover?.contentSize = NSSize(width: 300, height: 360)
        popover?.behavior = .transient
        popover?.contentViewController = NSHostingController(rootView: ContentView())
    }

    func startTimer() {
        timer?.invalidate()
        // Fix #4: always reads current refreshInterval so new setting takes effect immediately
        let interval = TimeInterval(UserDefaults.standard.integer(forKey: "refreshInterval").clamped(to: 30...900))
        timer = Timer.scheduledTimer(withTimeInterval: interval == 0 ? 60 : interval, repeats: true) { [weak self] _ in
            Task { @MainActor in
                let key = UserDefaults.standard.string(forKey: "apiKey") ?? ""
                if !key.isEmpty {
                    await UsageManager.shared.fetchUsage()
                    self?.updateStatusBarIcon()
                }
            }
        }
    }

    @objc func togglePopover() {
        guard let button = statusItem?.button else { return }

        if let popover = popover {
            if popover.isShown {
                popover.performClose(nil)
            } else {
                popover.show(relativeTo: button.bounds, of: button, preferredEdge: .maxY)
                popover.contentViewController?.view.window?.makeKey()
            }
        }
    }

    func applicationWillTerminate(_ notification: Notification) {
        timer?.invalidate()
    }
}

private extension Comparable {
    func clamped(to range: ClosedRange<Self>) -> Self {
        min(max(self, range.lowerBound), range.upperBound)
    }
}
