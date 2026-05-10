import SwiftUI
import MapKit
import NetCheckCore

struct GlobeMapView: View {
    let hops: [TracerouteHop]
    let activeIndex: Int
    @Binding var cameraPosition: MapCameraPosition

    var coordinates: [CLLocationCoordinate2D] {
        hops.compactMap { hop in
            guard let lat = hop.latitude, let lon = hop.longitude else { return nil }
            return CLLocationCoordinate2D(latitude: lat, longitude: lon)
        }
    }

    var body: some View {
        Map(position: $cameraPosition) {
            if coordinates.count >= 2 {
                MapPolyline(coordinates: coordinates)
                    .stroke(.yellow.opacity(0.8), lineWidth: 2)
            }
            ForEach(hops) { hop in
                if let lat = hop.latitude, let lon = hop.longitude {
                    let isActive = hop.id == (activeIndex >= 0 && activeIndex < hops.count ? hops[activeIndex].id : -1)
                    Annotation(hop.city ?? hop.ip ?? "?",
                               coordinate: CLLocationCoordinate2D(latitude: lat, longitude: lon)) {
                        Circle()
                            .fill(isActive ? Color.yellow : Color.white.opacity(0.8))
                            .frame(width: isActive ? 12 : 8, height: isActive ? 12 : 8)
                            .shadow(color: isActive ? .yellow : .clear, radius: 6)
                    }
                }
            }
        }
        .mapStyle(.imagery(elevation: .realistic))
        .ignoresSafeArea()
    }
}
