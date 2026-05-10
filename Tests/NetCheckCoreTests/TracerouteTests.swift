import Testing
@testable import NetCheckCore

@Suite("Traceroute")
struct TracerouteTests {

    @Test func parseNormalHop() {
        let hop = TracerouteService.parse(line: "2  10.0.0.1  8.456 ms", id: 1)
        #expect(hop?.ip == "10.0.0.1")
        #expect(hop?.latencyMs == 8.456)
        #expect(hop?.id == 1)
    }

    @Test func parseTimeout() {
        let hop = TracerouteService.parse(line: "3  * * *", id: 2)
        #expect(hop != nil)
        #expect(hop?.ip == nil)
        #expect(hop?.isTimeout == true)
    }

    @Test func parseHeader() {
        let hop = TracerouteService.parse(line: "traceroute to 8.8.8.8 (8.8.8.8), 64 hops max", id: 0)
        #expect(hop == nil)
    }

    @Test func hopIsTimeout() {
        let hop = TracerouteHop(id: 0, ip: nil, latencyMs: nil,
                                city: nil, country: nil, latitude: nil, longitude: nil, asn: nil)
        #expect(hop.isTimeout)
    }
}
