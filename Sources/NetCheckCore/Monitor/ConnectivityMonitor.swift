import Foundation
import Network

public actor ConnectivityMonitor {
    private let pathMonitor = NWPathMonitor()
    private let monitorQueue = DispatchQueue(label: "com.vincent.netcheck.monitor")
    private let pingService = PingService()

    public private(set) var status: ConnectivityStatus = .offline
    private var statusContinuations: [UUID: AsyncStream<ConnectivityStatus>.Continuation] = [:]

    public init() {}

    public func start() {
        pathMonitor.pathUpdateHandler = { [weak self] path in
            guard let self else { return }
            Task { await self.evaluate(path: path) }
        }
        pathMonitor.start(queue: monitorQueue)
    }

    public func stop() {
        pathMonitor.cancel()
    }

    public var statusStream: AsyncStream<ConnectivityStatus> {
        AsyncStream { continuation in
            let id = UUID()
            statusContinuations[id] = continuation
            continuation.yield(status)
            continuation.onTermination = { [weak self] _ in
                Task { await self?.removeContinuation(id: id) }
            }
        }
    }

    private func removeContinuation(id: UUID) {
        statusContinuations.removeValue(forKey: id)
    }

    private func evaluate(path: NWPath) async {
        guard path.status == .satisfied else {
            update(.offline); return
        }
        async let ping1 = pingService.ping(host: "1.1.1.1")
        async let ping2 = pingService.ping(host: "8.8.8.8")
        async let dnsOk = pingService.resolveDNS(host: "apple.com")

        let (p1, p2, dns) = await (ping1, ping2, dnsOk)
        let bestPing = [p1, p2].compactMap { $0 }.min()

        if !dns {
            update(.degraded(reason: .dnsFailure)); return
        }
        guard let ping = bestPing else {
            update(.degraded(reason: .packetLoss)); return
        }
        if ping > 300 {
            update(.degraded(reason: .highLatency)); return
        }

        let ssid = path.availableInterfaces.first?.name
        update(.connected(ping: ping, ssid: ssid))
    }

    private func update(_ newStatus: ConnectivityStatus) {
        status = newStatus
        for continuation in statusContinuations.values {
            continuation.yield(newStatus)
        }
    }
}
