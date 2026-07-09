import SwiftUI
import AppKit
import NetCheckCore
import NetCheckUI

struct WiFiScanView: View {
    @State private var vm = WiFiScanViewModel()
    @State private var groupBySSID = false

    var body: some View {
        FeatureWindowBackground(tintColor: .teal) {
            VStack(spacing: 16) {
                HStack {
                    Text("Diagnostic Wi-Fi")
                        .font(.title2.bold())
                    Spacer()
                    Button {
                        vm.refresh()
                    } label: {
                        Image(systemName: "arrow.clockwise")
                            .rotationEffect(.degrees(vm.isScanning ? 360 : 0))
                            .animation(vm.isScanning ? .linear(duration: 0.8).repeatForever(autoreverses: false) : .default, value: vm.isScanning)
                    }
                    .buttonStyle(.plain)
                    .disabled(vm.isScanning)
                }
                .padding(.horizontal)
                .padding(.top, 20)

                summaryLine
                    .padding(.horizontal)

                Toggle("Grouper les réseaux du même nom", isOn: $groupBySSID)
                    .toggleStyle(.checkbox)
                    .font(.caption)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal)

                if !vm.locationAuthorized {
                    authorizationBanner
                        .padding(.horizontal)
                }

                if let error = vm.errorMessage {
                    GlassPanelView {
                        HStack(spacing: 8) {
                            Image(systemName: "exclamationmark.triangle.fill")
                                .foregroundStyle(.orange)
                            Text(error)
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }
                    .padding(.horizontal)
                }

                ScrollView {
                    LazyVStack(spacing: 8) {
                        if groupBySSID {
                            ForEach(vm.groupedNetworks) { group in
                                NetworkGroupRow(group: group, congestion: vm.congestion)
                            }
                        } else {
                            ForEach(vm.networks) { network in
                                NetworkRow(network: network, congestion: vm.congestion(for: network))
                            }
                        }
                    }
                    .padding(.horizontal)
                    .padding(.bottom, 16)
                }
            }
        }
        .onAppear { vm.start() }
        .onDisappear { vm.stop() }
    }

    private var summaryLine: some View {
        HStack(spacing: 6) {
            Image(systemName: "wifi")
                .foregroundStyle(.teal)
            Text(summaryText)
                .font(.caption)
                .foregroundStyle(.secondary)
            Spacer()
        }
    }

    private var summaryText: String {
        let count = vm.networks.count
        guard count > 0 else { return vm.isScanning ? "Recherche des réseaux…" : "Aucun réseau détecté" }
        var parts = ["\(count) réseau\(count > 1 ? "x" : "") détecté\(count > 1 ? "s" : "")"]
        if vm.weakSecurityCount > 0 {
            parts.append("\(vm.weakSecurityCount) non sécurisé\(vm.weakSecurityCount > 1 ? "s" : "")")
        }
        return parts.joined(separator: " · ")
    }

    @ViewBuilder
    private var authorizationBanner: some View {
        GlassPanelView {
            HStack(alignment: .top, spacing: 10) {
                Image(systemName: vm.locationDenied ? "location.slash.fill" : "location.fill")
                    .foregroundStyle(vm.locationDenied ? .red : .orange)
                VStack(alignment: .leading, spacing: 4) {
                    Text(vm.locationDenied ? "Localisation refusée — réseaux non dissociés" : "Localisation requise pour dissocier chaque borne")
                        .font(.caption.weight(.semibold))
                    Text(vm.locationDenied
                        ? "Sans cette autorisation, macOS masque le nom et l'adresse (BSSID) de chaque point d'accès — plusieurs bornes portant le même nom apparaissent alors fusionnées en une seule ligne."
                        : "macOS a besoin de la localisation pour révéler le BSSID de chaque point d'accès Wi-Fi et distinguer deux bornes portant le même nom. Accordez l'autorisation dans la fenêtre système, ou ci-dessous.")
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                    if vm.locationDenied {
                        Button("Ouvrir Réglages Système…") {
                            if let url = URL(string: "x-apple.systempreferences:com.apple.preference.security?Privacy_LocationServices") {
                                NSWorkspace.shared.open(url)
                            }
                        }
                        .buttonStyle(.link)
                        .font(.caption2)
                    }
                }
                Spacer()
            }
        }
    }
}

private struct NetworkRow: View {
    let network: WiFiNetworkInfo
    let congestion: Int

    private var tintColor: Color {
        let strength = network.strength
        if strength > 0.6 { return .teal }
        if strength > 0.3 { return .orange }
        return .red
    }

    private var snrColor: Color {
        guard let snr = network.snr else { return .secondary }
        if snr >= 25 { return .green }
        if snr >= 15 { return .orange }
        return .red
    }

    var body: some View {
        GlassPanelView {
            VStack(alignment: .leading, spacing: 8) {
                HStack(spacing: 10) {
                    SignalBars(strength: network.strength, color: tintColor)

                    VStack(alignment: .leading, spacing: 2) {
                        HStack(spacing: 6) {
                            Text(network.displayName)
                                .font(.subheadline.weight(.semibold))
                                .lineLimit(1)
                            if network.isCurrent {
                                Tag(text: "Connecté", color: .teal)
                            }
                            if network.isAdHoc {
                                Tag(text: "Ad-hoc", color: .purple)
                            }
                        }
                        if let bssid = network.bssid {
                            Text(bssid)
                                .font(.caption2.monospaced())
                                .foregroundStyle(.tertiary)
                        }
                    }

                    Spacer()

                    VStack(alignment: .trailing, spacing: 2) {
                        Text("\(network.rssi) dBm")
                            .font(.caption.monospacedDigit().weight(.medium))
                        if let snr = network.snr {
                            Text("SNR \(snr) dB")
                                .font(.caption2.monospacedDigit())
                                .foregroundStyle(snrColor)
                        }
                    }
                }

                HStack(spacing: 10) {
                    if let channel = network.channelNumber {
                        Label(
                            "Canal \(channel)\(network.band.map { " · \($0)" } ?? "")\(network.channelWidth.map { " · \($0)" } ?? "")",
                            systemImage: "number"
                        )
                    }
                    if let phy = network.phyMode {
                        Label(phy, systemImage: "waveform")
                    }
                    Spacer()
                    SecurityBadge(security: network.security)
                }
                .font(.caption2)
                .foregroundStyle(.secondary)

                if congestion > 1 {
                    Label("\(congestion) réseaux détectés sur ce canal — risque d'interférence", systemImage: "exclamationmark.triangle.fill")
                        .font(.caption2)
                        .foregroundStyle(.orange)
                }
            }
        }
    }
}

private struct NetworkGroupRow: View {
    let group: WiFiScanViewModel.NetworkGroup
    let congestion: (WiFiNetworkInfo) -> Int
    @State private var expanded = false

    private var strongest: WiFiNetworkInfo { group.networks[0] }   // déjà trié par rssi desc

    private var tintColor: Color {
        let strength = strongest.strength
        if strength > 0.6 { return .teal }
        if strength > 0.3 { return .orange }
        return .red
    }

    var body: some View {
        // Un seul BSSID pour ce SSID : pas besoin de repli/disclosure, la ligne simple suffit
        if group.networks.count == 1 {
            NetworkRow(network: strongest, congestion: congestion(strongest))
        } else {
            GlassPanelView {
                DisclosureGroup(isExpanded: $expanded) {
                    VStack(spacing: 8) {
                        ForEach(group.networks) { network in
                            NetworkRow(network: network, congestion: congestion(network))
                        }
                    }
                    .padding(.top, 8)
                } label: {
                    HStack(spacing: 10) {
                        SignalBars(strength: strongest.strength, color: tintColor)
                        VStack(alignment: .leading, spacing: 2) {
                            HStack(spacing: 6) {
                                Text(group.displayName)
                                    .font(.subheadline.weight(.semibold))
                                    .lineLimit(1)
                                if group.networks.contains(where: \.isCurrent) {
                                    Tag(text: "Connecté", color: .teal)
                                }
                                Tag(text: "\(group.networks.count) bornes", color: .secondary)
                            }
                            Text("Meilleur signal \(strongest.rssi) dBm · \(strongest.label)")
                                .font(.caption2)
                                .foregroundStyle(.secondary)
                        }
                        Spacer()
                    }
                }
            }
        }
    }
}

private struct Tag: View {
    let text: String
    let color: Color

    var body: some View {
        Text(text)
            .font(.caption2.weight(.semibold))
            .foregroundStyle(color)
            .padding(.horizontal, 6)
            .padding(.vertical, 1)
            .background(color.opacity(0.15), in: Capsule())
    }
}

private struct SecurityBadge: View {
    let security: WiFiSecurityLevel

    private var color: Color {
        switch security {
        case .wpa3:            return .green
        case .wpa2:            return .blue
        case .wpa, .owe:       return .orange
        case .wep, .open:      return .red
        case .unknown:         return .secondary
        }
    }

    var body: some View {
        HStack(spacing: 3) {
            if security.isWeak {
                Image(systemName: "exclamationmark.triangle.fill")
                    .font(.system(size: 8))
            }
            Text(security.label)
        }
        .font(.caption2.weight(.semibold))
        .foregroundStyle(color)
        .padding(.horizontal, 6)
        .padding(.vertical, 2)
        .background(color.opacity(0.12), in: Capsule())
    }
}
