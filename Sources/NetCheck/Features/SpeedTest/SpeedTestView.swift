import SwiftUI
import NetCheckUI

struct SpeedTestView: View {
    @State private var vm = SpeedTestViewModel()

    var body: some View {
        FeatureWindowBackground(tintColor: .blue) {
            VStack(spacing: 24) {
                Text("Speed Test")
                    .font(.title2.bold())
                    .padding(.top, 20)

                HStack(spacing: 32) {
                    SpeedGauge(value: vm.download, maxValue: 1000,
                               label: "Téléchargement", icon: "arrow.down", color: .blue)
                    SpeedGauge(value: vm.upload, maxValue: 500,
                               label: "Envoi", icon: "arrow.up", color: .purple)
                }

                GlassPanelView {
                    VStack(spacing: 4) {
                        Text("\(vm.rpm)")
                            .font(.system(size: 40, weight: .bold, design: .rounded))
                            .monospacedDigit()
                            .foregroundStyle(.primary)
                        Text("RPM — \(vm.rpmLabel)")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                        Text("Responsiveness Per Minute (métrique Apple)")
                            .font(.caption2)
                            .foregroundStyle(.tertiary)
                    }
                    .frame(maxWidth: .infinity)
                }
                .padding(.horizontal)

                Button(vm.isRunning ? "Test en cours…" : "Démarrer") {
                    vm.start()
                }
                .buttonStyle(.borderedProminent)
                .disabled(vm.isRunning)
                .glassEffect(in: Capsule())

                Spacer()
            }
        }
    }
}
