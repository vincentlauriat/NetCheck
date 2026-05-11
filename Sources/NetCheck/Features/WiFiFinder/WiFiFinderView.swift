import SwiftUI
import NetCheckCore
import NetCheckUI

struct WiFiFinderView: View {
    @State private var vm = WiFiFinderViewModel()

    var body: some View {
        FeatureWindowBackground(tintColor: vm.tintColor) {
            VStack(spacing: 24) {
                Text("WiFi Finder")
                    .font(.title2.bold())
                    .padding(.top, 20)

                ZStack {
                    ConcentricWaves(color: vm.tintColor, duration: vm.waveDuration, strength: vm.signal.strength)
                    Image(systemName: "antenna.radiowaves.left.and.right")
                        .font(.system(size: 32, weight: .medium))
                        .foregroundStyle(vm.tintColor)
                        .symbolEffect(.pulse)
                }

                GlassPanelView {
                    HStack(spacing: 12) {
                        SignalBars(strength: vm.signal.strength, color: vm.tintColor)
                        VStack(alignment: .leading, spacing: 2) {
                            Text("\(vm.signal.rssi) dBm")
                                .font(.title3.monospacedDigit().bold())
                            Text(vm.signal.label)
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                        Spacer()
                        if let ssid = vm.signal.ssid {
                            Text(ssid)
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }
                }
                .padding(.horizontal)

                // Conseil contextuel selon la force du signal
                HStack(spacing: 6) {
                    Image(systemName: vm.moveTipIcon)
                        .font(.caption)
                        .foregroundStyle(vm.tintColor)
                    Text(vm.moveTip)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.leading)
                }
                .padding(.horizontal, 24)
                .frame(maxWidth: .infinity, alignment: .leading)
                .animation(.easeInOut(duration: 0.4), value: vm.signal.strength)

                GlassPanelView {
                    HStack {
                        Image(systemName: vm.soundEnabled ? "speaker.wave.2.fill" : "speaker.slash.fill")
                            .foregroundStyle(vm.tintColor)
                        Text(vm.soundEnabled
                            ? "Écoute les tics — déplace-toi pour trouver le meilleur signal"
                            : "Active le son pour le mode Geiger")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                        Spacer()
                        Toggle("", isOn: $vm.soundEnabled)
                            .labelsHidden()
                    }
                }
                .padding(.horizontal)

                Spacer()
            }
        }
        .onAppear { vm.start() }
        .onDisappear { vm.stop() }
    }
}

struct SignalBars: View {
    let strength: Double
    let color: Color

    var body: some View {
        HStack(alignment: .bottom, spacing: 3) {
            ForEach(0..<4, id: \.self) { i in
                RoundedRectangle(cornerRadius: 2)
                    .fill(Double(i) / 3 <= strength ? color : color.opacity(0.2))
                    .frame(width: 5, height: CGFloat(8 + i * 5))
            }
        }
    }
}
