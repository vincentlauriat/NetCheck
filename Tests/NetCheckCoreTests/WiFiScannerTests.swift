import Testing
@testable import NetCheckCore

@Suite("WiFiScanner")
struct WiFiScannerTests {

    @Test func wifiSignalStrengthBounds() {
        let max = WiFiSignal(rssi: -30, ssid: nil)
        let min = WiFiSignal(rssi: -90, ssid: nil)
        let mid = WiFiSignal(rssi: -60, ssid: nil)
        #expect(max.strength == 1.0)
        #expect(min.strength == 0.0)
        #expect(mid.strength > 0.4 && mid.strength < 0.6)
    }

    @Test func scannerStartStop() async throws {
        let scanner = WiFiScanner()
        await scanner.start()
        try await Task.sleep(for: .milliseconds(300))
        await scanner.stop()
    }

    @Test func geigerIntervalFormula() {
        let strong = WiFiSignal(rssi: -30, ssid: nil)
        let weak_ = WiFiSignal(rssi: -90, ssid: nil)
        // Fort → 80ms, faible → 2000ms
        let strongInterval = 80 + Int((1 - strong.strength) * 1920)
        let weakInterval = 80 + Int((1 - weak_.strength) * 1920)
        #expect(strongInterval == 80)
        #expect(weakInterval == 2000)
    }
}
