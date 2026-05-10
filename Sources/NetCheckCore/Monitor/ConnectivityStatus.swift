import Foundation

public enum DegradedReason: Sendable {
    case highLatency
    case packetLoss
    case dnsFailure
}

public enum ConnectivityStatus: Sendable {
    case connected(ping: Int, ssid: String?)
    case degraded(reason: DegradedReason)
    case offline

    public var color: StatusColor {
        switch self {
        case .connected: return .green
        case .degraded:  return .orange
        case .offline:   return .red
        }
    }
}

public enum StatusColor: Sendable { case green, orange, red }
