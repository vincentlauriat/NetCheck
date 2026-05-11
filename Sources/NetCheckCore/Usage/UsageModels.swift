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

    // Seuils de latence hiérarchiques : gaming est le plus exigeant, mail le plus tolérant.
    // Garantie : si gaming = Excellent, tous les profils le sont aussi.
    public func quality(for latencyMs: Double) -> QualityLevel {
        switch self {
        case .mail:
            switch latencyMs {
            case ..<150:  return .excellent
            case ..<400:  return .good
            case ..<800:  return .fair
            default:      return .poor
            }
        case .workspace:
            switch latencyMs {
            case ..<80:   return .excellent
            case ..<200:  return .good
            case ..<400:  return .fair
            default:      return .poor
            }
        case .videoConf:
            switch latencyMs {
            case ..<40:   return .excellent
            case ..<80:   return .good
            case ..<150:  return .fair
            default:      return .poor
            }
        case .gaming:
            switch latencyMs {
            case ..<20:   return .excellent
            case ..<50:   return .good
            case ..<80:   return .fair
            default:      return .poor
            }
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
