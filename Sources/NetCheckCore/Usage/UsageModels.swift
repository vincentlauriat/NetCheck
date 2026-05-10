import Foundation

public enum UsageProfile: String, CaseIterable, Sendable {
    case mail       = "Mail"
    case workspace  = "Workspace"
    case videoConf  = "Vidéo conf"
    case gaming     = "Jeux en ligne"

    public var icon: String {
        switch self {
        case .mail:      return "envelope.fill"
        case .workspace: return "doc.richtext.fill"
        case .videoConf: return "video.fill"
        case .gaming:    return "gamecontroller.fill"
        }
    }
}

public enum QualityLevel: Sendable {
    case excellent, good, fair, poor

    public var label: String {
        switch self {
        case .excellent: return "Excellent"
        case .good:      return "Bon"
        case .fair:      return "Moyen"
        case .poor:      return "Mauvais"
        }
    }
}

public struct UsageResult: Sendable {
    public let profile: UsageProfile
    public let quality: QualityLevel
    public let latencyMs: Double

    public init(profile: UsageProfile, quality: QualityLevel, latencyMs: Double) {
        self.profile = profile; self.quality = quality; self.latencyMs = latencyMs
    }
}
