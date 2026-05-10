import AppKit
import SwiftUI
import NetCheckCore

@MainActor
final class AppDelegate: NSObject, NSApplicationDelegate {
    private var statusMenuController: StatusMenuController?

    func applicationDidFinishLaunching(_ notification: Notification) {
        NSApp.setActivationPolicy(.accessory)
        statusMenuController = StatusMenuController()
        statusMenuController?.setup()
    }
}
