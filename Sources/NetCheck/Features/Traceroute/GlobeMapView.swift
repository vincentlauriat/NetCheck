import SwiftUI
import MapKit
import NetCheckCore

struct GlobeMapView: View {
    let hops: [TracerouteHop]
    let activeIndex: Int
    @Binding var cameraPosition: MapCameraPosition
    let planeCoordinate: CLLocationCoordinate2D?
    let planeHeading: Double
    let planePath: [CLLocationCoordinate2D]

    var hopCoordinates: [CLLocationCoordinate2D] {
        hops.compactMap { hop in
            guard let lat = hop.latitude, let lon = hop.longitude else { return nil }
            return CLLocationCoordinate2D(latitude: lat, longitude: lon)
        }
    }

    var body: some View {
        Map(position: $cameraPosition) {
            // Trajet de l'avion (trail pointillé blanc)
            if planePath.count >= 2 {
                MapPolyline(coordinates: planePath)
                    .stroke(.white.opacity(0.55), style: StrokeStyle(lineWidth: 2, dash: [6, 4]))
            }

            // Ligne entre les hops géolocalisés
            if hopCoordinates.count >= 2 {
                MapPolyline(coordinates: hopCoordinates)
                    .stroke(.yellow.opacity(0.5), lineWidth: 1.5)
            }

            // Pins de localisation pour chaque hop
            ForEach(hops) { hop in
                if let lat = hop.latitude, let lon = hop.longitude {
                    let isActive = hop.id == (activeIndex >= 0 && activeIndex < hops.count ? hops[activeIndex].id : -1)
                    Annotation(hop.city ?? hop.ip ?? "", coordinate: CLLocationCoordinate2D(latitude: lat, longitude: lon)) {
                        Image(systemName: "mappin.circle.fill")
                            .font(.system(size: isActive ? 20 : 13))
                            .foregroundStyle(isActive ? Color.yellow : Color.white)
                            .shadow(color: isActive ? .yellow.opacity(0.9) : .black.opacity(0.5),
                                    radius: isActive ? 8 : 2)
                            .animation(.spring(duration: 0.3), value: isActive)
                    }
                }
            }

            // Avion animé — .id(planeHeading) force MapKit à recréer la vue si le cap change
            if let coord = planeCoordinate {
                Annotation("", coordinate: coord) {
                    Image(systemName: "airplane")
                        .font(.title2)
                        .foregroundStyle(.yellow)
                        .rotationEffect(.degrees(planeHeading - 45))
                        .shadow(color: .black.opacity(0.8), radius: 4)
                        .id(planeHeading)
                }
            }
        }
        .mapStyle(.imagery(elevation: .realistic))
        .ignoresSafeArea()
    }
}
