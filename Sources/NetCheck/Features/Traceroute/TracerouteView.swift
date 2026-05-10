import SwiftUI
import NetCheckUI

struct TracerouteView: View {
    @State private var vm = TracerouteViewModel()

    var body: some View {
        ZStack(alignment: .bottom) {
            GlobeMapView(hops: vm.hops, activeIndex: vm.activeHopIndex,
                         cameraPosition: $vm.cameraPosition)

            VStack(spacing: 8) {
                if vm.activeHopIndex >= 0, vm.activeHopIndex < vm.hops.count {
                    let hop = vm.hops[vm.activeHopIndex]
                    GlassPanelView {
                        HStack {
                            VStack(alignment: .leading, spacing: 2) {
                                Text("Hop \(hop.id + 1) · \(hop.city ?? hop.ip ?? "?")")
                                    .font(.caption.weight(.semibold))
                                if let country = hop.country {
                                    Text(country).font(.caption2).foregroundStyle(.secondary)
                                }
                            }
                            Spacer()
                            if let ms = hop.latencyMs {
                                Text(String(format: "%.0f ms", ms))
                                    .font(.caption.monospacedDigit().bold())
                            }
                            if let asn = hop.asn {
                                Text(asn.components(separatedBy: " ").first ?? "")
                                    .font(.caption2)
                                    .foregroundStyle(.secondary)
                            }
                        }
                    }
                    .padding(.horizontal)
                }

                HopListView(hops: vm.hops, activeIndex: vm.activeHopIndex)
                    .padding(.vertical, 4)

                HStack(spacing: 12) {
                    Button("Démarrer") { vm.start() }
                        .disabled(vm.isRunning)
                    Button("Rejouer") { vm.replay() }
                        .disabled(vm.isRunning)
                }
                .buttonStyle(.borderedProminent)
                .padding(.bottom, 16)
            }
        }
        .frame(width: 600, height: 500)
    }
}
