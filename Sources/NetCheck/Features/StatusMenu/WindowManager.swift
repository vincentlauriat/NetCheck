import AppKit
import SwiftUI

@MainActor
enum WindowManager {
    enum Feature { case wifiFinder, speedTest, traceroute, usage, settings }

    private static var panels: [Feature: NSPanel] = [:]

    static func open(_ feature: Feature) {
        if let existing = panels[feature] {
            existing.makeKeyAndOrderFront(nil)
            return
        }
        let panel = makePanel(for: feature)
        panels[feature] = panel
        panel.makeKeyAndOrderFront(nil)
    }

    private static func makePanel(for feature: Feature) -> NSPanel {
        let (view, size): (AnyView, NSSize) = switch feature {
        case .wifiFinder: (AnyView(WiFiFinderView()), NSSize(width: 340, height: 460))
        case .speedTest:  (AnyView(SpeedTestView()),  NSSize(width: 360, height: 480))
        case .traceroute: (AnyView(TracerouteView()), NSSize(width: 600, height: 500))
        case .usage:      (AnyView(UsageView()),       NSSize(width: 340, height: 480))
        case .settings:   (AnyView(PreferencesView()), NSSize(width: 380, height: 300))
        }
        let panel = NSPanel(
            contentRect: NSRect(origin: .zero, size: size),
            styleMask: [.titled, .closable, .fullSizeContentView, .nonactivatingPanel],
            backing: .buffered,
            defer: false
        )
        panel.level = .floating
        panel.titlebarAppearsTransparent = true
        panel.isMovableByWindowBackground = true
        panel.contentViewController = NSHostingController(rootView: view)
        panel.center()
        return panel
    }
}

extension WindowManager.Feature: Hashable {}
