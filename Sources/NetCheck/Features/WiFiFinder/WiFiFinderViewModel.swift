import SwiftUI
import NetCheckCore

@MainActor
@Observable
final class WiFiFinderViewModel {
    private(set) var signal: WiFiSignal = WiFiSignal(rssi: -70, ssid: nil)
    var soundEnabled: Bool = true {
        didSet { soundEnabled ? geigerEngine.setSignal(signal) : geigerEngine.stop() }
    }

    private let scanner = WiFiScanner()
    private let geigerEngine = GeigerSoundEngine()
    private var scanTask: Task<Void, Never>?

    func start() {
        Task { await scanner.start() }
        scanTask = Task {
            for await s in await scanner.signalStream {
                signal = s
                if soundEnabled { geigerEngine.setSignal(s) }
            }
        }
    }

    func stop() {
        scanTask?.cancel()
        Task { await scanner.stop() }
        geigerEngine.stop()
    }

    var tintColor: Color {
        let strength = signal.strength
        if strength > 0.6 { return .blue }
        if strength > 0.3 { return .orange }
        return .red
    }

    var waveDuration: Double {
        0.7 + (1 - signal.strength) * 3.8    // 0.7s (fort) → 4.5s (faible)
    }

    var moveTip: String {
        switch signal.strength {
        case 0.7...: return "Signal optimal — vous êtes bien positionné"
        case 0.4...: return "Déplacez-vous lentement pour trouver un meilleur signal"
        default:     return "Signal faible — rapprochez-vous du routeur ou changez de pièce"
        }
    }

    var moveTipIcon: String {
        switch signal.strength {
        case 0.7...: return "checkmark.circle.fill"
        case 0.4...: return "figure.walk"
        default:     return "exclamationmark.triangle.fill"
        }
    }
}
