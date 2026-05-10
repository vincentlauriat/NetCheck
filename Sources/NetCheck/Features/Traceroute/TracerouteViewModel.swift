import SwiftUI
import MapKit
import NetCheckCore

@MainActor
@Observable
final class TracerouteViewModel {
    private(set) var hops: [TracerouteHop] = []
    private(set) var activeHopIndex: Int = -1
    private(set) var isRunning = false
    var cameraPosition = MapCameraPosition.camera(
        MapCamera(centerCoordinate: CLLocationCoordinate2D(latitude: 20, longitude: 0),
                  distance: 8_000_000, heading: 0, pitch: 0)
    )

    private let tracerouteService = TracerouteService()
    private let geoService = GeoIPService()
    private var traceTask: Task<Void, Never>?

    func start(destination: String = "8.8.8.8") {
        guard !isRunning else { return }
        isRunning = true; hops = []; activeHopIndex = -1
        resetCamera()
        traceTask = Task {
            await tracerouteService.setDestination(destination)
            for await hop in await tracerouteService.run() {
                let enriched = await geoService.locate(hop: hop)
                hops.append(enriched)
                await animateTo(hop: enriched)
            }
            isRunning = false
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
                distance: 8_000_000, heading: 0, pitch: 0
            ))
        }
    }

    private func animateTo(hop: TracerouteHop) async {
        guard let lat = hop.latitude, let lon = hop.longitude else { return }
        let coord = CLLocationCoordinate2D(latitude: lat, longitude: lon)
        let idx = hops.firstIndex(where: { $0.id == hop.id }) ?? 0
        activeHopIndex = idx

        withAnimation(.easeInOut(duration: 2.0)) {
            cameraPosition = .camera(MapCamera(centerCoordinate: coord,
                                               distance: 800_000, heading: 0, pitch: 20))
        }
        try? await Task.sleep(for: .seconds(2))
        withAnimation(.easeInOut(duration: 1.5)) {
            cameraPosition = .camera(MapCamera(centerCoordinate: coord,
                                               distance: 15_000, heading: 0, pitch: 45))
        }
        try? await Task.sleep(for: .seconds(2))

        withAnimation(.easeInOut(duration: 1.5)) {
            cameraPosition = .camera(MapCamera(centerCoordinate: coord,
                                               distance: 2_000_000, heading: 0, pitch: 0))
        }
        try? await Task.sleep(for: .seconds(1))
    }
}

extension TracerouteService {
    func setDestination(_ dest: String) async { destination = dest }
}
