import Foundation

public struct WiFiSignal: Sendable {
    public let rssi: Int        // dBm, typiquement -30 à -90
    public let ssid: String?

    public var strength: Double {
        // Normalise -30 (1.0) à -90 (0.0)
        max(0, min(1, Double(rssi + 90) / 60.0))
    }

    public var label: String {
        switch rssi {
        case (-50)...: return "Excellent"
        case (-65)...: return "Bon"
        case (-75)...: return "Moyen"
        default:       return "Faible"
        }
    }

    public init(rssi: Int, ssid: String?) {
        self.rssi = rssi; self.ssid = ssid
    }
}
