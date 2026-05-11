import Foundation

public actor SpeedTestService {
    public init() {}

    // networkQuality -c produit un seul JSON complet à la fin du test.
    // Champs réels : dl_throughput, ul_throughput (octets/s), dl_responsiveness, ul_responsiveness (RPM).
    public func run() -> AsyncStream<SpeedTestProgress> {
        AsyncStream { continuation in
            Task {
                let process = Process()
                process.executableURL = URL(fileURLWithPath: "/usr/bin/networkQuality")
                process.arguments = ["-s", "-c"]
                let pipe = Pipe()
                process.standardOutput = pipe
                process.standardError = Pipe()

                do {
                    try process.run()
                } catch {
                    continuation.finish()
                    return
                }

                let data = pipe.fileHandleForReading.readDataToEndOfFile()
                process.waitUntilExit()

                // networkQuality -s produit plusieurs lignes JSON (une par phase).
                // On parse chaque ligne et on moyenne les valeurs pour obtenir la vraie moyenne.
                let lines = (String(data: data, encoding: .utf8) ?? "")
                    .components(separatedBy: .newlines)
                    .filter { !$0.trimmingCharacters(in: .whitespaces).isEmpty }

                var dlSum = 0.0, ulSum = 0.0, dlRpmSum = 0.0, ulRpmSum = 0.0
                var rttSum = 0.0, rttCount = 0, validCount = 0

                for line in lines {
                    guard let lineData = line.data(using: .utf8),
                          let json = try? JSONSerialization.jsonObject(with: lineData) as? [String: Any]
                    else { continue }
                    dlSum    += (json["dl_throughput"]    as? NSNumber)?.doubleValue ?? 0
                    ulSum    += (json["ul_throughput"]    as? NSNumber)?.doubleValue ?? 0
                    dlRpmSum += (json["dl_responsiveness"] as? NSNumber)?.doubleValue ?? 0
                    ulRpmSum += (json["ul_responsiveness"] as? NSNumber)?.doubleValue ?? 0
                    if let rtt = (json["base_rtt"] as? NSNumber)?.doubleValue { rttSum += rtt; rttCount += 1 }
                    validCount += 1
                }

                guard validCount > 0 else { continuation.finish(); return }

                let n = Double(validCount)
                let rpm = Int((dlRpmSum + ulRpmSum) / (2 * n))
                let latency = rttCount > 0 ? rttSum / Double(rttCount)
                                           : (rpm > 0 ? 60_000.0 / Double(rpm) : 0)

                continuation.yield(SpeedTestProgress(
                    downloadMbps: dlSum / (n * 1_000_000),
                    uploadMbps:   ulSum / (n * 1_000_000),
                    rpm: rpm,
                    latencyMs: latency,
                    isComplete: true
                ))
                continuation.finish()
            }
        }
    }
}
