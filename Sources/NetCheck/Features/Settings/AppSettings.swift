import Foundation
import ServiceManagement

@Observable
final class AppSettings: @unchecked Sendable {
    static let shared = AppSettings()

    var launchAtLogin: Bool {
        get { SMAppService.mainApp.status == .enabled }
        set {
            do {
                if newValue { try SMAppService.mainApp.register() }
                else { try SMAppService.mainApp.unregister() }
            } catch { print("SMAppService error: \(error)") }
        }
    }

    var geigerSoundEnabled: Bool {
        get { UserDefaults.standard.bool(forKey: "geigerSoundEnabled") || true }
        set { UserDefaults.standard.set(newValue, forKey: "geigerSoundEnabled") }
    }

    var tracerouteDestination: String {
        get { UserDefaults.standard.string(forKey: "tracerouteDestination") ?? "8.8.8.8" }
        set { UserDefaults.standard.set(newValue, forKey: "tracerouteDestination") }
    }

    private init() {}
}
