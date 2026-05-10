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
        1.5 + (1 - signal.strength) * 2.5
    }
}
