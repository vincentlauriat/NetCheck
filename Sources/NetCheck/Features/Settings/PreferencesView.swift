import SwiftUI
import Sparkle

struct PreferencesView: View {
    @State private var settings = AppSettings.shared
    private let updater = SPUStandardUpdaterController(
        startingUpdater: true, updaterDelegate: nil, userDriverDelegate: nil
    )

    var body: some View {
        Form {
            Section("Général") {
                Toggle("Lancer au démarrage", isOn: $settings.launchAtLogin)
                Toggle("Son Geiger WiFi", isOn: $settings.geigerSoundEnabled)
            }

            Section("Traceroute") {
                TextField("Destination", text: $settings.tracerouteDestination)
                    .textFieldStyle(.roundedBorder)
                Text("Adresse IP ou hostname (défaut : 8.8.8.8)")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Section("À propos") {
                HStack {
                    Text("NetCheck")
                        .font(.headline)
                    Spacer()
                    Text(Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0.0")
                        .foregroundStyle(.secondary)
                }
                Link("GitHub", destination: URL(string: "https://github.com/vincentlauriat/NetCheck")!)
                Button("Vérifier les mises à jour…") {
                    updater.updater.checkForUpdates()
                }
            }
        }
        .formStyle(.grouped)
        .padding()
        .frame(width: 380, height: 300)
    }
}
