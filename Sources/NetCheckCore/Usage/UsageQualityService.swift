import Foundation

public struct UsageQualityService: Sendable {
    public init() {}

    // Mesure la latence une seule fois vers un endpoint neutre,
    // puis déduit la qualité pour chaque profil selon ses seuils propres.
    public func evaluate() async -> [UsageResult] {
        let latencyMs = await measureLatency()
        return UsageProfile.allCases.map { profile in
            UsageResult(profile: profile, quality: profile.quality(for: latencyMs), latencyMs: latencyMs)
        }
    }

    // Yield les résultats un par un pour les animations de la vue.
    public func stream() -> AsyncStream<UsageResult> {
        AsyncStream { continuation in
            Task {
                let latencyMs = await measureLatency()
                for profile in UsageProfile.allCases {
                    continuation.yield(UsageResult(
                        profile: profile,
                        quality: profile.quality(for: latencyMs),
                        latencyMs: latencyMs
                    ))
                    try? await Task.sleep(for: .milliseconds(180))
                }
                continuation.finish()
            }
        }
    }

    // Moyenne de 3 HEAD requests vers 1.1.1.1 (Cloudflare — neutre, stable, mondial).
    private func measureLatency() async -> Double {
        let samples = await withTaskGroup(of: Double.self) { group in
            for _ in 0..<3 {
                group.addTask { await self.ping() }
            }
            var results: [Double] = []
            for await v in group { results.append(v) }
            return results
        }
        let valid = samples.filter { $0 < 5000 }
        guard !valid.isEmpty else { return 999 }
        return valid.reduce(0, +) / Double(valid.count)
    }

    private func ping() async -> Double {
        guard let url = URL(string: "https://1.1.1.1") else { return 999 }
        var request = URLRequest(url: url, timeoutInterval: 5)
        request.httpMethod = "HEAD"
        let start = Date()
        _ = try? await URLSession.shared.data(for: request)
        return Date().timeIntervalSince(start) * 1000
    }
}
