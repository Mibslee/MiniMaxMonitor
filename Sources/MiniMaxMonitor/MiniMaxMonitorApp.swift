import SwiftUI

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
        
        if !apiKey.isEmpty {
            Task {
                await UsageManager.shared.fetchUsage()
                updateStatusBarIcon()
            }
        }
    }
    
    func setupStatusItem() {
        statusItem = NSStatusBar.system.statusItem(withLength: 50)
        
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
        let size = NSSize(width: 22, height: 22)
        let image = NSImage(size: size)
        
        image.lockFocus()
        
        let center = NSPoint(x: size.width / 2, y: size.height / 2)
        let radius: CGFloat = 8
        let lineWidth: CGFloat = 2.5
        
        let usedPercentage = 100 - percentage
        let ringColor = NSColor.green
        
        let backgroundPath = NSBezierPath()
        backgroundPath.appendArc(withCenter: center, radius: radius, startAngle: 0, endAngle: 360)
        backgroundPath.lineWidth = lineWidth
        ringColor.withAlphaComponent(0.2).setStroke()
        backgroundPath.stroke()
        
        let startAngle: CGFloat = 90
        let endAngle: CGFloat = startAngle - CGFloat(usedPercentage / 100 * 360)
        
        if usedPercentage > 0 {
            let foregroundPath = NSBezierPath()
            foregroundPath.appendArc(withCenter: center, radius: radius, startAngle: startAngle, endAngle: endAngle, clockwise: true)
            foregroundPath.lineWidth = lineWidth
            foregroundPath.lineCapStyle = .round
            ringColor.setStroke()
            foregroundPath.stroke()
        }
        
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = .center
        
        let attributes: [NSAttributedString.Key: Any] = [
            .font: NSFont.systemFont(ofSize: 10, weight: .bold),
            .foregroundColor: ringColor,
            .paragraphStyle: paragraphStyle
        ]
        
        let text = "m"
        let textSize = text.size(withAttributes: attributes)
        let textRect = NSRect(
            x: center.x - textSize.width / 2,
            y: center.y - textSize.height / 2 + 1,
            width: textSize.width,
            height: textSize.height
        )
        text.draw(in: textRect, withAttributes: attributes)
        
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
        timer = Timer.scheduledTimer(withTimeInterval: TimeInterval(refreshInterval), repeats: true) { [weak self] _ in
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
                popover.show(relativeTo: button.bounds, of: button, preferredEdge: .minY)
                popover.contentViewController?.view.window?.makeKey()
            }
        }
    }
    
    func applicationWillTerminate(_ notification: Notification) {
        timer?.invalidate()
    }
}