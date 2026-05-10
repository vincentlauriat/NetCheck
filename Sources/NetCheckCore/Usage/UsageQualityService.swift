import Foundation

public actor UsageQualityService {
    public init() {}

    public func evaluate() async -> [UsageResult] {
        await withTaskGroup(of: UsageResult.self) { group in
            for profile in UsageProfile.allCases {
                group.addTask { await self.test(profile: profile) }
            }
            var results: [UsageResult] = []
            for await result in group { results.append(result) }
            return results.sorted { $0.profile.rawValue < $1.profile.rawValue }
        }
    }

    private func test(profile: UsageProfile) async -> UsageResult {
        let (host, threshold): (String, Double) = switch profile {
        case .mail:      ("smtp.gmail.com", 150)
        case .workspace: ("docs.google.com", 200)
        case .videoConf: ("zoom.us", 100)
        case .gaming:    ("1.1.1.1", 50)
        }

        let latency = await measureTCPLatency(host: host, port: 443)
        let quality: QualityLevel = switch latency {
        case ..<(threshold * 0.5):  .excellent
        case ..<threshold:           .good
        case ..<(threshold * 1.5):  .fair
        default:                     .poor
        }
        return UsageResult(profile: profile, quality: quality, latencyMs: latency)
    }

    private func measureTCPLatency(host: String, port: Int) async -> Double {
        let process = Process()
        process.executableURL = URL(fileURLWithPath: "/usr/bin/nc")
        process.arguments = ["-z", "-w", "2", host, "\(port)"]
        process.standardOutput = Pipe()
        process.standardError = Pipe()
        let start = Date()
        do {
            try process.run()
            process.waitUntilExit()
            return Date().timeIntervalSince(start) * 1000
        } catch {
            return 999
        }
    }
}
