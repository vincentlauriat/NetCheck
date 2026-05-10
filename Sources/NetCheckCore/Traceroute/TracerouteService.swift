import Foundation

public actor TracerouteService {
    public var destination: String = "8.8.8.8"
    public init() {}

    public func run() -> AsyncStream<TracerouteHop> {
        let dest = destination
        return AsyncStream { continuation in
            Task {
                let process = Process()
                process.executableURL = URL(fileURLWithPath: "/usr/sbin/traceroute")
                process.arguments = ["-n", "-q", "1", "-w", "2", dest]
                let pipe = Pipe()
                process.standardOutput = pipe
                process.standardError = Pipe()

                do {
                    try process.run()
                } catch {
                    continuation.finish()
                    return
                }

                var hopId = 0
                let handle = pipe.fileHandleForReading
                while true {
                    let data = handle.availableData
                    if data.isEmpty { break }
                    guard let text = String(data: data, encoding: .utf8) else { continue }
                    for rawLine in text.components(separatedBy: "\n") {
                        if let hop = TracerouteService.parse(line: rawLine, id: hopId) {
                            hopId += 1
                            continuation.yield(hop)
                        }
                    }
                }

                process.waitUntilExit()
                continuation.finish()
            }
        }
    }

    public static func parse(line: String, id: Int) -> TracerouteHop? {
        let trimmed = line.trimmingCharacters(in: .whitespaces)
        guard !trimmed.isEmpty, trimmed.first?.isNumber == true else { return nil }

        if trimmed.contains("* * *") {
            return TracerouteHop(id: id, ip: nil, latencyMs: nil,
                                 city: nil, country: nil, latitude: nil, longitude: nil, asn: nil)
        }

        let parts = trimmed.components(separatedBy: .whitespaces).filter { !$0.isEmpty }
        guard parts.count >= 3 else { return nil }
        let ip = parts[1]
        let latency = Double(parts[2])
        return TracerouteHop(id: id, ip: ip, latencyMs: latency,
                             city: nil, country: nil, latitude: nil, longitude: nil, asn: nil)
    }
}
