import Foundation

public actor SpeedTestService {
    public init() {}

    public func run() -> AsyncStream<SpeedTestProgress> {
        AsyncStream { continuation in
            Task {
                let process = Process()
                process.executableURL = URL(fileURLWithPath: "/usr/bin/networkQuality")
                process.arguments = ["-s", "-f", "json-extended"]
                let pipe = Pipe()
                process.standardOutput = pipe
                process.standardError = Pipe()

                pipe.fileHandleForReading.readabilityHandler = { handle in
                    let data = handle.availableData
                    guard !data.isEmpty,
                          let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any]
                    else { return }

                    let dl = (json["dl_throughput"] as? Double ?? 0) / 1_000_000
                    let ul = (json["ul_throughput"] as? Double ?? 0) / 1_000_000
                    let rpm = json["responsiveness"] as? Int ?? 0
                    let done = json["test_progress"] as? Double == 1.0

                    continuation.yield(SpeedTestProgress(
                        downloadMbps: dl, uploadMbps: ul, rpm: rpm, isComplete: done
                    ))
                    if done { continuation.finish() }
                }

                do {
                    try process.run()
                    process.waitUntilExit()
                    continuation.finish()
                } catch {
                    continuation.finish()
                }
            }
        }
    }
}
