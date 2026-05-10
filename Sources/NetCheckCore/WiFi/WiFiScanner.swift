import Foundation
import CoreWLAN

public actor WiFiScanner {
    private var scanTask: Task<Void, Never>?
    private nonisolated(unsafe) var signalContinuations: [UUID: AsyncStream<WiFiSignal>.Continuation] = [:]

    public init() {}

    public func start() {
        scanTask = Task { [weak self] in
            while !Task.isCancelled {
                if let signal = await self?.currentSignal() {
                    await self?.emit(signal)
                }
                try? await Task.sleep(for: .milliseconds(250))
            }
        }
    }

    public func stop() {
        scanTask?.cancel()
        scanTask = nil
    }

    public var signalStream: AsyncStream<WiFiSignal> {
        AsyncStream { continuation in
            let id = UUID()
            signalContinuations[id] = continuation
            continuation.onTermination = { [weak self] _ in
                Task { await self?.signalContinuations.removeValue(forKey: id) }
            }
        }
    }

    private func currentSignal() -> WiFiSignal? {
        guard let iface = CWWiFiClient.shared().interface() else { return nil }
        let rssi = iface.rssiValue()
        guard rssi != 0 else { return nil }
        return WiFiSignal(rssi: rssi, ssid: iface.ssid())
    }

    private func emit(_ signal: WiFiSignal) {
        for cont in signalContinuations.values { cont.yield(signal) }
    }
}
