import Foundation

public actor GeoIPService {
    private var cache: [String: TracerouteHop] = [:]
    public init() {}

    public func locate(hop: TracerouteHop) async -> TracerouteHop {
        guard let ip = hop.ip else { return hop }
        if let cached = cache[ip] { return cached }

        guard let url = URL(string: "http://ip-api.com/json/\(ip)?fields=country,city,lat,lon,as") else { return hop }
        guard let (data, _) = try? await URLSession.shared.data(from: url),
              let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any]
        else { return hop }

        let enriched = TracerouteHop(
            id: hop.id, ip: ip,
            latencyMs: hop.latencyMs,
            city: json["city"] as? String,
            country: json["country"] as? String,
            latitude: json["lat"] as? Double,
            longitude: json["lon"] as? Double,
            asn: json["as"] as? String
        )
        cache[ip] = enriched
        return enriched
    }
}
