import Foundation

public struct TracerouteHop: Identifiable, Sendable {
    public let id: Int
    public let ip: String?
    public let latencyMs: Double?
    public let city: String?
    public let country: String?
    public let latitude: Double?
    public let longitude: Double?
    public let asn: String?

    public var isTimeout: Bool { ip == nil }

    public init(id: Int, ip: String?, latencyMs: Double?, city: String?,
                country: String?, latitude: Double?, longitude: Double?, asn: String?) {
        self.id = id; self.ip = ip; self.latencyMs = latencyMs
        self.city = city; self.country = country
        self.latitude = latitude; self.longitude = longitude; self.asn = asn
    }
}
