import Foundation

// Normalise -30 dBm (1.0) à -90 dBm (0.0) — partagé entre WiFiSignal et WiFiNetworkInfo
func wifiStrength(forRSSI rssi: Int) -> Double {
    max(0, min(1, Double(rssi + 90) / 60.0))
}

func wifiLabel(forRSSI rssi: Int) -> String {
    switch rssi {
    case (-50)...: return "Excellent"
    case (-65)...: return "Bon"
    case (-75)...: return "Moyen"
    default:       return "Faible"
    }
}

public struct WiFiSignal: Sendable {
    public let rssi: Int        // dBm, typiquement -30 à -90
    public let ssid: String?

    public var strength: Double { wifiStrength(forRSSI: rssi) }
    public var label: String { wifiLabel(forRSSI: rssi) }

    public init(rssi: Int, ssid: String?) {
        self.rssi = rssi; self.ssid = ssid
    }
}

public enum WiFiSecurityLevel: Sendable {
    case open, owe, wep, wpa, wpa2, wpa3, unknown

    public var label: String {
        switch self {
        case .open:    return "Ouvert"
        case .owe:     return "OWE"
        case .wep:     return "WEP"
        case .wpa:     return "WPA"
        case .wpa2:    return "WPA2"
        case .wpa3:    return "WPA3"
        case .unknown: return "Inconnu"
        }
    }

    // Réseaux sans chiffrement robuste — à signaler dans le diagnostic
    public var isWeak: Bool {
        switch self {
        case .open, .wep: return true
        default:          return false
        }
    }
}

// Un point d'accès individuel (une entrée par BSSID) — plusieurs WiFiNetworkInfo
// peuvent partager le même SSID (mesh, extenders) sans être regroupés.
public struct WiFiNetworkInfo: Sendable, Identifiable, Hashable {
    public let id: String
    public let ssid: String?
    public let bssid: String?
    public let rssi: Int
    public let noise: Int?
    public let channelNumber: Int?
    public let band: String?
    public let channelWidth: String?
    public let phyMode: String?
    public let security: WiFiSecurityLevel
    public let isAdHoc: Bool
    public let isCurrent: Bool

    public var strength: Double { wifiStrength(forRSSI: rssi) }
    public var label: String { wifiLabel(forRSSI: rssi) }
    public var displayName: String { ssid?.isEmpty == false ? ssid! : "Réseau masqué" }
    // Rapport signal/bruit (dB) — plus il est élevé, plus la liaison est propre
    public var snr: Int? { noise.map { rssi - $0 } }

    public init(
        id: String, ssid: String?, bssid: String?, rssi: Int, noise: Int?,
        channelNumber: Int?, band: String?, channelWidth: String?, phyMode: String?,
        security: WiFiSecurityLevel, isAdHoc: Bool, isCurrent: Bool
    ) {
        self.id = id; self.ssid = ssid; self.bssid = bssid; self.rssi = rssi; self.noise = noise
        self.channelNumber = channelNumber; self.band = band
        self.channelWidth = channelWidth; self.phyMode = phyMode
        self.security = security; self.isAdHoc = isAdHoc; self.isCurrent = isCurrent
    }
}
