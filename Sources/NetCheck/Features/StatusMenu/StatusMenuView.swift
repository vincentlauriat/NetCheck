import SwiftUI
import NetCheckCore

struct StatusMenuView: View {
    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Image(systemName: "globe")
                    .foregroundStyle(.green)
                    .font(.title2)
                VStack(alignment: .leading, spacing: 2) {
                    Text("NetCheck")
                        .font(.headline)
                    Text("Connecté")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                Spacer()
            }
            .padding()
            .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 8))

            Divider()

            Group {
                MenuRowButton(icon: "antenna.radiowaves.left.and.right", label: "WiFi Finder") {
                    WindowManager.open(.wifiFinder)
                }
                MenuRowButton(icon: "bolt.fill", label: "Speed Test") {
                    WindowManager.open(.speedTest)
                }
                MenuRowButton(icon: "map.fill", label: "Traceroute") {
                    WindowManager.open(.traceroute)
                }
                MenuRowButton(icon: "chart.bar.fill", label: "Usage") {
                    WindowManager.open(.usage)
                }
            }

            Divider()

            MenuRowButton(icon: "gearshape.fill", label: "Préférences") {
                WindowManager.open(.settings)
            }
            MenuRowButton(icon: "power", label: "Quitter") {
                NSApp.terminate(nil)
            }
        }
        .frame(width: 300)
    }
}

struct MenuRowButton: View {
    let icon: String
    let label: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack {
                Image(systemName: icon)
                    .frame(width: 20)
                Text(label)
                Spacer()
                Image(systemName: "chevron.right")
                    .foregroundStyle(.tertiary)
                    .font(.caption)
            }
            .padding(.horizontal)
            .padding(.vertical, 8)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }
}
