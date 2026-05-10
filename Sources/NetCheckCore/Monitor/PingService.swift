import Foundation

actor PingService {
    func ping(host: String, timeoutSeconds: Double = 2.0) async -> Int? {
        let process = Process()
        process.executableURL = URL(fileURLWithPath: "/sbin/ping")
        process.arguments = ["-c", "1", "-W", "1", host]
        let pipe = Pipe()
        process.standardOutput = pipe
        process.standardError = Pipe()

        do {
            try process.run()
            let deadline = Date().addingTimeInterval(timeoutSeconds)
            while process.isRunning && Date() < deadline {
                try await Task.sleep(for: .milliseconds(50))
            }
            if process.isRunning { process.terminate(); return nil }
            let data = pipe.fileHandleForReading.readDataToEndOfFile()
            let output = String(data: data, encoding: .utf8) ?? ""
            // Parse: "round-trip min/avg/max/stddev = 1.234/1.234/1.234/0.000 ms"
            if let range = output.range(of: #"= [\d.]+/([\d.]+)/"#, options: .regularExpression),
               let numRange = output[range].range(of: #"[\d.]+"#, options: .regularExpression,
                   range: output[range].index(output[range].startIndex, offsetBy: 2)..<output[range].endIndex) {
                return Int(Double(output[numRange]) ?? 999)
            }
            return nil
        } catch {
            return nil
        }
    }

    func resolveDNS(host: String) async -> Bool {
        await withCheckedContinuation { continuation in
            DispatchQueue.global().async {
                var hints = addrinfo()
                hints.ai_socktype = Int32(SOCK_STREAM.rawValue)
                var result: UnsafeMutablePointer<addrinfo>?
                let code = getaddrinfo(host, nil, &hints, &result)
                if result != nil { freeaddrinfo(result) }
                continuation.resume(returning: code == 0)
            }
        }
    }
}
