import Testing
@testable import NetCheckCore

@Suite("ConnectivityMonitor")
struct ConnectivityMonitorTests {

    @Test func initialStatusIsOffline() async {
        let monitor = ConnectivityMonitor()
        let status = await monitor.status
        if case .offline = status { } else {
            Issue.record("Expected offline, got \(status)")
        }
    }

    @Test func startAndReceiveStatus() async throws {
        let monitor = ConnectivityMonitor()
        await monitor.start()
        var received: ConnectivityStatus?
        for await s in await monitor.statusStream {
            received = s; break
        }
        await monitor.stop()
        #expect(received != nil)
    }
}
