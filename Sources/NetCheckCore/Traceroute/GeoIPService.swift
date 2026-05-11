import Foundation

public actor GeoIPService {
    private var cache: [String: TracerouteHop] = [:]
    public init() {}

    // ipinfo.io: HTTPS gratuit, 50k req/mois, pas de clé API
    // Réponse: { city, country (ISO 2), loc: "lat,lon", org: "AS### Name" }
    public func locate(hop: TracerouteHop) async -> TracerouteHop {
        guard let ip = hop.ip else { return hop }
        if let cached = cache[ip] { return cached }

        guard let url = URL(string: "https://ipinfo.io/\(ip)/json") else { return hop }
        guard let (data, _) = try? await URLSession.shared.data(from: url),
              let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any]
        else { return hop }

        var lat: Double? = nil
        var lon: Double? = nil
        if let loc = json["loc"] as? String {
            let parts = loc.components(separatedBy: ",")
            if parts.count == 2 {
                lat = Double(parts[0])
                lon = Double(parts[1])
            }
        }

        let enriched = TracerouteHop(
            id: hop.id, ip: ip,
            latencyMs: hop.latencyMs,
            city: json["city"] as? String,
            country: json["country"] as? String,
            latitude: lat,
            longitude: lon,
            asn: json["org"] as? String
        )
        cache[ip] = enriched
        return enriched
    }
}
