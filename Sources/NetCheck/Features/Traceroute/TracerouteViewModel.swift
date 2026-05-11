import SwiftUI
import MapKit
import NetCheckCore

@MainActor
@Observable
final class TracerouteViewModel {
    var destination = "8.8.8.8"
    private(set) var hops: [TracerouteHop] = []
    private(set) var activeHopIndex: Int = -1
    private(set) var isRunning = false
    private(set) var planeCoordinate: CLLocationCoordinate2D? = nil
    private(set) var planeHeading: Double = 0
    private(set) var planePath: [CLLocationCoordinate2D] = []
    var cameraPosition = MapCameraPosition.camera(
        MapCamera(centerCoordinate: CLLocationCoordinate2D(latitude: 20, longitude: 0),
                  distance: 24_000_000, heading: 0, pitch: 0)
    )

    private let tracerouteService = TracerouteService()
    private let geoService = GeoIPService()
    private var traceTask: Task<Void, Never>?
    private var previousHopCoord: CLLocationCoordinate2D? = nil

    func start() {
        guard !isRunning else { return }
        isRunning = true; hops = []; activeHopIndex = -1
        planeCoordinate = nil; previousHopCoord = nil; planePath = []
        resetCamera()
        traceTask = Task {
            await tracerouteService.setDestination(destination)
            for await hop in await tracerouteService.run() {
                let enriched = await geoService.locate(hop: hop)
                hops.append(enriched)
                await animateTo(hop: enriched)
            }
            planeCoordinate = nil
            isRunning = false
            await zoomOutToOverview()
        }
    }

    func replay() {
        traceTask?.cancel()
        isRunning = false
        start()
    }

    private func resetCamera() {
        withAnimation(.easeInOut(duration: 1.5)) {
            cameraPosition = .camera(MapCamera(
                centerCoordinate: CLLocationCoordinate2D(latitude: 20, longitude: 0),
                distance: 24_000_000, heading: 0, pitch: 0
            ))
        }
    }

    private func zoomOutToOverview() async {
        try? await Task.sleep(for: .milliseconds(400))
        withAnimation(.easeInOut(duration: 2.5)) {
            cameraPosition = .camera(MapCamera(
                centerCoordinate: CLLocationCoordinate2D(latitude: 20, longitude: 0),
                distance: 24_000_000, heading: 0, pitch: 0
            ))
        }
    }

    private func animateTo(hop: TracerouteHop) async {
        guard let lat = hop.latitude, let lon = hop.longitude else { return }
        let dest = CLLocationCoordinate2D(latitude: lat, longitude: lon)
        let idx = hops.firstIndex(where: { $0.id == hop.id }) ?? 0
        activeHopIndex = idx

        if let from = previousHopCoord {
            // Cadre les deux points pendant le vol
            let midLat = (from.latitude + dest.latitude) / 2
            let midLon = (from.longitude + dest.longitude) / 2
            let mid = CLLocationCoordinate2D(latitude: midLat, longitude: midLon)
            let spanDeg = max(abs(dest.latitude - from.latitude), abs(dest.longitude - from.longitude))
            let flightDist = max(300_000, spanDeg * 80_000)
            withAnimation(.easeInOut(duration: 0.6)) {
                cameraPosition = .camera(MapCamera(centerCoordinate: mid,
                                                   distance: flightDist, heading: 0, pitch: 15))
            }
            try? await Task.sleep(for: .milliseconds(1400))
            await flyPlane(from: from, to: dest)
        } else {
            planeCoordinate = dest
            withAnimation(.easeInOut(duration: 1.5)) {
                cameraPosition = .camera(MapCamera(centerCoordinate: dest,
                                                   distance: 1_500_000, heading: 0, pitch: 0))
            }
            try? await Task.sleep(for: .milliseconds(3000))
        }

        // Zoom très proche de la Terre
        withAnimation(.easeOut(duration: 1.0)) {
            cameraPosition = .camera(MapCamera(centerCoordinate: dest,
                                               distance: 80_000, heading: 0, pitch: 55))
        }
        try? await Task.sleep(for: .milliseconds(2400))

        // Remonte à altitude de croisière
        withAnimation(.easeInOut(duration: 0.8)) {
            cameraPosition = .camera(MapCamera(centerCoordinate: dest,
                                               distance: 1_500_000, heading: 0, pitch: 0))
        }
        try? await Task.sleep(for: .milliseconds(1400))

        previousHopCoord = dest
    }

    private func flyPlane(from: CLLocationCoordinate2D, to: CLLocationCoordinate2D) async {
        let steps = 30
        let heading = Self.bearing(from: from, to: to)
        planeHeading = heading

        for step in 1...steps {
            guard !Task.isCancelled else { return }
            let t = Double(step) / Double(steps)
            let lat = from.latitude + (to.latitude - from.latitude) * t
            let lon = from.longitude + (to.longitude - from.longitude) * t
            let coord = CLLocationCoordinate2D(latitude: lat, longitude: lon)
            planeCoordinate = coord
            planePath.append(coord)
            // Caméra fixe — seule la position de l'avion change
            try? await Task.sleep(for: .milliseconds(60))
        }
    }

    static func bearing(from: CLLocationCoordinate2D, to: CLLocationCoordinate2D) -> Double {
        let lat1 = from.latitude * .pi / 180
        let lat2 = to.latitude * .pi / 180
        let dLon = (to.longitude - from.longitude) * .pi / 180
        let y = sin(dLon) * cos(lat2)
        let x = cos(lat1) * sin(lat2) - sin(lat1) * cos(lat2) * cos(dLon)
        return (atan2(y, x) * 180 / .pi + 360).truncatingRemainder(dividingBy: 360)
    }
}

extension TracerouteService {
    func setDestination(_ dest: String) async { destination = dest }
}
