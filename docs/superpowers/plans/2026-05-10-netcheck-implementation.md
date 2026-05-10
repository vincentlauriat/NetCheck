# NetCheck Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Application macOS menu bar affichant la connectivité internet (globe vert/orange/rouge) avec 5 outils : WiFi Finder Geiger, Speed Test, Traceroute globe 3D, Usage qualité, Préférences.

**Architecture:** 3 targets XcodeGen — `NetCheckCore` (logique réseau, acteurs Swift 6, zéro UI), `NetCheckUI` (composants SwiftUI Liquid Glass réutilisables), `NetCheck` (app, assembly). Build via `xcodegen` + `xcodebuild` CLI uniquement. Sparkle 2.9.1 pour les mises à jour.

**Tech Stack:** Swift 6.3, SwiftUI, macOS 26 SDK, XcodeGen, Network.framework, CoreWLAN, AVFoundation, MapKit, Sparkle 2.9.1

---

## Task 1 : Scaffolding du projet

**Files:**
- Create: `project.yml`
- Create: `Sources/NetCheck/Info.plist`
- Create: `Sources/NetCheck/NetCheck.entitlements`
- Create: `Sources/NetCheckCore/.gitkeep`
- Create: `Sources/NetCheckUI/.gitkeep`
- Create: `Tests/NetCheckCoreTests/.gitkeep`
- Create: `Scripts/build.sh`

- [ ] **Créer l'arborescence des dossiers**

```bash
mkdir -p Sources/NetCheckCore/{Monitor,WiFi,SpeedTest,Traceroute,Usage}
mkdir -p Sources/NetCheckUI
mkdir -p Sources/NetCheck/{App,Features/{StatusMenu,WiFiFinder,SpeedTest,Traceroute,Usage,Settings},Resources/Assets.xcassets/AppIcon.appiconset}
mkdir -p Tests/NetCheckCoreTests
mkdir -p Scripts
touch Sources/NetCheckCore/.gitkeep
touch Sources/NetCheckUI/.gitkeep
touch Tests/NetCheckCoreTests/.gitkeep
```

- [ ] **Créer `project.yml`**

```yaml
name: NetCheck
options:
  bundleIdPrefix: com.vincent
  deploymentTarget:
    macOS: "26.0"
  createIntermediateGroups: true
  generateEmptyDirectories: true
  groupSortPosition: top
  xcodeVersion: "26.0"

packages:
  Sparkle:
    url: https://github.com/sparkle-project/Sparkle
    from: "2.9.1"

settings:
  base:
    SWIFT_VERSION: "6.0"
    DEVELOPMENT_TEAM: "KFLACS69T9"
    ENABLE_HARDENED_RUNTIME: YES
    MACOSX_DEPLOYMENT_TARGET: "26.0"
    SWIFT_STRICT_CONCURRENCY: complete

targets:
  NetCheckCore:
    type: framework
    platform: macOS
    sources:
      - path: Sources/NetCheckCore
    settings:
      base:
        PRODUCT_BUNDLE_IDENTIFIER: com.vincent.NetCheckCore
        PRODUCT_NAME: NetCheckCore
        CODE_SIGN_IDENTITY: "-"

  NetCheckUI:
    type: framework
    platform: macOS
    sources:
      - path: Sources/NetCheckUI
    dependencies:
      - target: NetCheckCore
    settings:
      base:
        PRODUCT_BUNDLE_IDENTIFIER: com.vincent.NetCheckUI
        PRODUCT_NAME: NetCheckUI
        CODE_SIGN_IDENTITY: "-"

  NetCheck:
    type: application
    platform: macOS
    sources:
      - path: Sources/NetCheck
      - path: Sources/NetCheck/Resources/Assets.xcassets
        buildPhase: resources
    dependencies:
      - package: Sparkle
      - target: NetCheckCore
        embed: true
      - target: NetCheckUI
        embed: true
    info:
      path: Sources/NetCheck/Info.plist
      properties:
        CFBundleDisplayName: NetCheck
        CFBundleShortVersionString: "1.0.0"
        CFBundleVersion: "1"
        LSMinimumSystemVersion: "26.0"
        LSUIElement: true
        NSHighResolutionCapable: true
        NSPrincipalClass: NSApplication
        NSSupportsAutomaticGraphicsSwitching: true
        NSLocalNetworkUsageDescription: "NetCheck monitors your internet connectivity."
        SUFeedURL: "https://raw.githubusercontent.com/vincentlauriat/NetCheck/main/appcast.xml"
        SUPublicEDKey: "PLACEHOLDER"
        SUEnableAutomaticChecks: true
        SUScheduledCheckInterval: 86400
        SUAutomaticallyUpdate: false
        CODE_SIGN_ENTITLEMENTS: Sources/NetCheck/NetCheck.entitlements
    settings:
      base:
        PRODUCT_BUNDLE_IDENTIFIER: com.vincent.NetCheck
        PRODUCT_NAME: NetCheck
        MARKETING_VERSION: "1.0.0"
        CURRENT_PROJECT_VERSION: "1"
        ASSETCATALOG_COMPILER_APPICON_NAME: AppIcon
        CODE_SIGN_IDENTITY: "Developer ID Application"
        CODE_SIGN_STYLE: Manual
        CODE_SIGN_ENTITLEMENTS: Sources/NetCheck/NetCheck.entitlements

  NetCheckCoreTests:
    type: bundle.unit-test
    platform: macOS
    sources:
      - path: Tests/NetCheckCoreTests
    dependencies:
      - target: NetCheckCore
    settings:
      base:
        PRODUCT_BUNDLE_IDENTIFIER: com.vincent.NetCheckCoreTests
        CODE_SIGN_IDENTITY: "-"
```

- [ ] **Créer `Sources/NetCheck/NetCheck.entitlements`**

```xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>com.apple.security.network.client</key>
    <true/>
</dict>
</plist>
```

- [ ] **Créer `Sources/NetCheck/Info.plist`** (vide — XcodeGen le génère)

```xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict/>
</plist>
```

- [ ] **Créer `Sources/NetCheck/Resources/Assets.xcassets/Contents.json`**

```json
{ "info": { "author": "xcode", "version": 1 } }
```

- [ ] **Créer `Sources/NetCheck/Resources/Assets.xcassets/AppIcon.appiconset/Contents.json`**

```json
{
  "images": [
    { "idiom": "mac", "scale": "1x", "size": "16x16" },
    { "idiom": "mac", "scale": "2x", "size": "16x16" },
    { "idiom": "mac", "scale": "1x", "size": "32x32" },
    { "idiom": "mac", "scale": "2x", "size": "32x32" },
    { "idiom": "mac", "scale": "1x", "size": "128x128" },
    { "idiom": "mac", "scale": "2x", "size": "128x128" },
    { "idiom": "mac", "scale": "1x", "size": "256x256" },
    { "idiom": "mac", "scale": "2x", "size": "256x256" },
    { "idiom": "mac", "scale": "1x", "size": "512x512" },
    { "idiom": "mac", "scale": "2x", "size": "512x512" }
  ],
  "info": { "author": "xcode", "version": 1 }
}
```

- [ ] **Créer `Scripts/build.sh`**

```bash
#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT"

if ! command -v xcodegen >/dev/null 2>&1; then
  echo "✗ XcodeGen non installé. brew install xcodegen" >&2; exit 1
fi

echo "→ Génération du projet Xcode…"
xcodegen generate

echo "→ Build Debug…"
xcodebuild -project NetCheck.xcodeproj \
  -scheme NetCheck \
  -configuration Debug \
  -derivedDataPath build \
  CODE_SIGNING_ALLOWED=NO 2>&1 | tail -5

APP="$ROOT/build/Build/Products/Debug/NetCheck.app"
echo "✅ Build OK : $APP"
if [ "${1:-}" = "run" ]; then open "$APP"; fi
```

```bash
chmod +x Scripts/build.sh
```

- [ ] **Créer le stub `Sources/NetCheck/App/NetCheckApp.swift`** (minimal pour que le build passe)

```swift
import SwiftUI

@main
struct NetCheckApp: App {
    var body: some Scene {
        Settings { EmptyView() }
    }
}
```

- [ ] **Générer et builder**

```bash
xcodegen generate
./Scripts/build.sh
```

Résultat attendu : `✅ Build OK : .../NetCheck.app`

- [ ] **Commit**

```bash
git add project.yml Scripts/ Sources/ Tests/ .gitignore
git commit -m "feat: scaffolding projet XcodeGen + structure SPM 3 targets"
```

---

## Task 2 : Modèles de données (NetCheckCore)

**Files:**
- Create: `Sources/NetCheckCore/Monitor/ConnectivityStatus.swift`
- Create: `Sources/NetCheckCore/SpeedTest/SpeedTestModels.swift`
- Create: `Sources/NetCheckCore/Traceroute/TracerouteModels.swift`
- Create: `Sources/NetCheckCore/Usage/UsageModels.swift`
- Create: `Sources/NetCheckCore/WiFi/WiFiModels.swift`
- Create: `Tests/NetCheckCoreTests/ModelsTests.swift`

- [ ] **Créer `Sources/NetCheckCore/Monitor/ConnectivityStatus.swift`**

```swift
import Foundation

public enum DegradedReason: Sendable {
    case highLatency
    case packetLoss
    case dnsFailure
}

public enum ConnectivityStatus: Sendable {
    case connected(ping: Int, ssid: String?)
    case degraded(reason: DegradedReason)
    case offline

    public var color: StatusColor {
        switch self {
        case .connected: return .green
        case .degraded:  return .orange
        case .offline:   return .red
        }
    }
}

public enum StatusColor: Sendable { case green, orange, red }
```

- [ ] **Créer `Sources/NetCheckCore/SpeedTest/SpeedTestModels.swift`**

```swift
import Foundation

public struct SpeedTestProgress: Sendable {
    public let downloadMbps: Double
    public let uploadMbps: Double
    public let rpm: Int
    public let isComplete: Bool

    public init(downloadMbps: Double, uploadMbps: Double, rpm: Int, isComplete: Bool) {
        self.downloadMbps = downloadMbps
        self.uploadMbps = uploadMbps
        self.rpm = rpm
        self.isComplete = isComplete
    }
}
```

- [ ] **Créer `Sources/NetCheckCore/Traceroute/TracerouteModels.swift`**

```swift
import Foundation

public struct TracerouteHop: Identifiable, Sendable {
    public let id: Int
    public let ip: String?
    public let latencyMs: Double?
    public let city: String?
    public let country: String?
    public let latitude: Double?
    public let longitude: Double?
    public let asn: String?

    public var isTimeout: Bool { ip == nil }

    public init(id: Int, ip: String?, latencyMs: Double?, city: String?,
                country: String?, latitude: Double?, longitude: Double?, asn: String?) {
        self.id = id; self.ip = ip; self.latencyMs = latencyMs
        self.city = city; self.country = country
        self.latitude = latitude; self.longitude = longitude; self.asn = asn
    }
}
```

- [ ] **Créer `Sources/NetCheckCore/Usage/UsageModels.swift`**

```swift
import Foundation

public enum UsageProfile: String, CaseIterable, Sendable {
    case mail       = "Mail"
    case workspace  = "Workspace"
    case videoConf  = "Vidéo conf"
    case gaming     = "Jeux en ligne"

    public var icon: String {
        switch self {
        case .mail:      return "envelope.fill"
        case .workspace: return "doc.richtext.fill"
        case .videoConf: return "video.fill"
        case .gaming:    return "gamecontroller.fill"
        }
    }
}

public enum QualityLevel: Sendable {
    case excellent, good, fair, poor

    public var label: String {
        switch self {
        case .excellent: return "Excellent"
        case .good:      return "Bon"
        case .fair:      return "Moyen"
        case .poor:      return "Mauvais"
        }
    }
}

public struct UsageResult: Sendable {
    public let profile: UsageProfile
    public let quality: QualityLevel
    public let latencyMs: Double

    public init(profile: UsageProfile, quality: QualityLevel, latencyMs: Double) {
        self.profile = profile; self.quality = quality; self.latencyMs = latencyMs
    }
}
```

- [ ] **Créer `Sources/NetCheckCore/WiFi/WiFiModels.swift`**

```swift
import Foundation

public struct WiFiSignal: Sendable {
    public let rssi: Int        // dBm, typiquement -30 à -90
    public let ssid: String?

    public var strength: Double {
        // Normalise -30 (1.0) à -90 (0.0)
        max(0, min(1, Double(rssi + 90) / 60.0))
    }

    public var label: String {
        switch rssi {
        case (-50)...: return "Excellent"
        case (-65)...: return "Bon"
        case (-75)...: return "Moyen"
        default:       return "Faible"
        }
    }

    public init(rssi: Int, ssid: String?) {
        self.rssi = rssi; self.ssid = ssid
    }
}
```

- [ ] **Écrire le test `Tests/NetCheckCoreTests/ModelsTests.swift`**

```swift
import Testing
@testable import NetCheckCore

@Suite("Models")
struct ModelsTests {

    @Test func wifiStrengthExcellent() {
        let s = WiFiSignal(rssi: -30, ssid: nil)
        #expect(s.strength == 1.0)
        #expect(s.label == "Excellent")
    }

    @Test func wifiStrengthFaible() {
        let s = WiFiSignal(rssi: -90, ssid: nil)
        #expect(s.strength == 0.0)
        #expect(s.label == "Faible")
    }

    @Test func connectivityColor() {
        #expect(ConnectivityStatus.connected(ping: 10, ssid: nil).color == .green)
        #expect(ConnectivityStatus.degraded(reason: .highLatency).color == .orange)
        #expect(ConnectivityStatus.offline.color == .red)
    }

    @Test func usageProfileCases() {
        #expect(UsageProfile.allCases.count == 4)
    }
}
```

- [ ] **Lancer les tests**

```bash
xcodebuild test -project NetCheck.xcodeproj -scheme NetCheckCoreTests \
  -destination 'platform=macOS' 2>&1 | grep -E "(PASS|FAIL|error:)"
```

Résultat attendu : tous les tests `PASS`.

- [ ] **Commit**

```bash
git add Sources/NetCheckCore/ Tests/
git commit -m "feat: modèles de données NetCheckCore (ConnectivityStatus, SpeedTest, Traceroute, Usage, WiFi)"
```

---

## Task 3 : ConnectivityMonitor

**Files:**
- Create: `Sources/NetCheckCore/Monitor/ConnectivityMonitor.swift`
- Create: `Sources/NetCheckCore/Monitor/PingService.swift`
- Create: `Tests/NetCheckCoreTests/ConnectivityMonitorTests.swift`

- [ ] **Créer `Sources/NetCheckCore/Monitor/PingService.swift`**

```swift
import Foundation

actor PingService {
    func ping(host: String, timeoutSeconds: Double = 2.0) async -> Int? {
        let process = Process()
        process.executableURL = URL(fileURLWithPath: "/sbin/ping")
        process.arguments = ["-c", "1", "-W", "1", host]
        let pipe = Pipe()
        process.standardOutput = pipe
        process.standardError = Pipe()

        do {
            try process.run()
            let deadline = Date().addingTimeInterval(timeoutSeconds)
            while process.isRunning && Date() < deadline {
                try await Task.sleep(for: .milliseconds(50))
            }
            if process.isRunning { process.terminate(); return nil }
            let data = pipe.fileHandleForReading.readDataToEndOfFile()
            let output = String(data: data, encoding: .utf8) ?? ""
            // Parse: "round-trip min/avg/max/stddev = 1.234/1.234/1.234/0.000 ms"
            if let range = output.range(of: #"= [\d.]+/([\d.]+)/"#, options: .regularExpression),
               let numRange = output[range].range(of: #"[\d.]+"#, options: .regularExpression, range: output[range].index(output[range].startIndex, offsetBy: 2)..<output[range].endIndex) {
                return Int(Double(output[numRange]) ?? 999)
            }
            return nil
        } catch {
            return nil
        }
    }

    func resolveDNS(host: String) async -> Bool {
        await withCheckedContinuation { continuation in
            DispatchQueue.global().async {
                var hints = addrinfo()
                hints.ai_socktype = Int32(SOCK_STREAM.rawValue)
                var result: UnsafeMutablePointer<addrinfo>?
                let code = getaddrinfo(host, nil, &hints, &result)
                if result != nil { freeaddrinfo(result) }
                continuation.resume(returning: code == 0)
            }
        }
    }
}
```

- [ ] **Créer `Sources/NetCheckCore/Monitor/ConnectivityMonitor.swift`**

```swift
import Foundation
import Network

public actor ConnectivityMonitor {
    private let pathMonitor = NWPathMonitor()
    private let monitorQueue = DispatchQueue(label: "com.vincent.netcheck.monitor")
    private let pingService = PingService()

    public private(set) var status: ConnectivityStatus = .offline
    private var statusContinuations: [UUID: AsyncStream<ConnectivityStatus>.Continuation] = [:]

    public init() {}

    public func start() {
        pathMonitor.pathUpdateHandler = { [weak self] path in
            guard let self else { return }
            Task { await self.evaluate(path: path) }
        }
        pathMonitor.start(queue: monitorQueue)
    }

    public func stop() {
        pathMonitor.cancel()
    }

    public var statusStream: AsyncStream<ConnectivityStatus> {
        AsyncStream { continuation in
            let id = UUID()
            statusContinuations[id] = continuation
            continuation.yield(status)
            continuation.onTermination = { [weak self] _ in
                Task { await self?.removeContinuation(id: id) }
            }
        }
    }

    private func removeContinuation(id: UUID) {
        statusContinuations.removeValue(forKey: id)
    }

    private func evaluate(path: NWPath) async {
        guard path.status == .satisfied else {
            update(.offline); return
        }
        // Test ping + DNS en parallèle
        async let ping1 = pingService.ping(host: "1.1.1.1")
        async let ping2 = pingService.ping(host: "8.8.8.8")
        async let dnsOk = pingService.resolveDNS(host: "apple.com")

        let (p1, p2, dns) = await (ping1, ping2, dnsOk)
        let bestPing = [p1, p2].compactMap { $0 }.min()

        if !dns {
            update(.degraded(reason: .dnsFailure)); return
        }
        guard let ping = bestPing else {
            update(.degraded(reason: .packetLoss)); return
        }
        if ping > 300 {
            update(.degraded(reason: .highLatency)); return
        }

        let ssid = path.availableInterfaces.first?.name
        update(.connected(ping: ping, ssid: ssid))
    }

    private func update(_ newStatus: ConnectivityStatus) {
        status = newStatus
        for continuation in statusContinuations.values {
            continuation.yield(newStatus)
        }
    }
}
```

- [ ] **Écrire `Tests/NetCheckCoreTests/ConnectivityMonitorTests.swift`**

```swift
import Testing
@testable import NetCheckCore

@Suite("ConnectivityMonitor")
struct ConnectivityMonitorTests {

    @Test func initialStatusIsOffline() async {
        let monitor = ConnectivityMonitor()
        let status = await monitor.status
        // Avant start(), le statut est offline
        if case .offline = status { } else {
            Issue.record("Expected offline, got \(status)")
        }
    }

    @Test func startAndReceiveStatus() async throws {
        let monitor = ConnectivityMonitor()
        await monitor.start()
        // Attend le premier statut (max 5s)
        var received: ConnectivityStatus?
        for await s in await monitor.statusStream {
            received = s; break
        }
        await monitor.stop()
        #expect(received != nil)
    }
}
```

- [ ] **Lancer les tests**

```bash
xcodebuild test -project NetCheck.xcodeproj -scheme NetCheckCoreTests \
  -destination 'platform=macOS' 2>&1 | grep -E "(PASS|FAIL|error:)"
```

- [ ] **Commit**

```bash
git add Sources/NetCheckCore/Monitor/ Tests/NetCheckCoreTests/
git commit -m "feat: ConnectivityMonitor — NWPathMonitor + ping + DNS"
```

---

## Task 4 : App skeleton + menu bar

**Files:**
- Modify: `Sources/NetCheck/App/NetCheckApp.swift`
- Create: `Sources/NetCheck/App/AppDelegate.swift`
- Create: `Sources/NetCheck/Features/StatusMenu/StatusMenuController.swift`
- Create: `Sources/NetCheck/Features/StatusMenu/StatusMenuView.swift`

- [ ] **Réécrire `Sources/NetCheck/App/NetCheckApp.swift`**

```swift
import SwiftUI

@main
struct NetCheckApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var delegate

    var body: some Scene {
        Settings { PreferencesView() }
    }
}
```

- [ ] **Créer `Sources/NetCheck/App/AppDelegate.swift`**

```swift
import AppKit
import SwiftUI
import NetCheckCore

@MainActor
final class AppDelegate: NSObject, NSApplicationDelegate {
    private var statusMenuController: StatusMenuController?

    func applicationDidFinishLaunching(_ notification: Notification) {
        NSApp.setActivationPolicy(.accessory)
        statusMenuController = StatusMenuController()
        statusMenuController?.setup()
    }
}
```

- [ ] **Créer `Sources/NetCheck/Features/StatusMenu/StatusMenuController.swift`**

```swift
import AppKit
import SwiftUI
import NetCheckCore
import NetCheckUI

@MainActor
final class StatusMenuController {
    private let statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
    private var popover: NSPopover?
    private let monitor = ConnectivityMonitor()
    private var monitorTask: Task<Void, Never>?

    func setup() {
        let button = statusItem.button!
        button.image = NSImage(systemSymbolName: "globe", accessibilityDescription: "NetCheck")
        button.image?.isTemplate = false
        button.action = #selector(togglePopover)
        button.target = self

        let popover = NSPopover()
        popover.contentSize = NSSize(width: 300, height: 420)
        popover.behavior = .transient
        popover.contentViewController = NSHostingController(rootView: StatusMenuView())
        self.popover = popover

        Task { await monitor.start() }
        monitorTask = Task {
            for await status in await monitor.statusStream {
                updateIcon(for: status)
            }
        }
    }

    private func updateIcon(for status: ConnectivityStatus) {
        guard let button = statusItem.button else { return }
        let name: String
        let color: NSColor
        switch status {
        case .connected:  name = "globe"; color = .systemGreen
        case .degraded:   name = "globe"; color = .systemOrange
        case .offline:    name = "globe"; color = .systemRed
        }
        let config = NSImage.SymbolConfiguration(pointSize: 16, weight: .medium)
            .applying(.init(paletteColors: [color]))
        button.image = NSImage(systemSymbolName: name, accessibilityDescription: "NetCheck")?
            .withSymbolConfiguration(config)
    }

    @objc private func togglePopover() {
        guard let button = statusItem.button, let popover else { return }
        if popover.isShown {
            popover.performClose(nil)
        } else {
            popover.show(relativeTo: button.bounds, of: button, preferredEdge: .minY)
        }
    }
}
```

- [ ] **Créer `Sources/NetCheck/Features/StatusMenu/StatusMenuView.swift`**

```swift
import SwiftUI
import NetCheckCore

struct StatusMenuView: View {
    var body: some View {
        VStack(spacing: 0) {
            // Header statut
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
            .glassEffect()

            Divider()

            // Entrées menu
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
```

- [ ] **Créer `Sources/NetCheck/Features/StatusMenu/WindowManager.swift`**

```swift
import AppKit
import SwiftUI

@MainActor
enum WindowManager {
    enum Feature { case wifiFinder, speedTest, traceroute, usage, settings }

    private static var panels: [Feature: NSPanel] = [:]

    static func open(_ feature: Feature) {
        if let existing = panels[feature] {
            existing.makeKeyAndOrderFront(nil)
            return
        }
        let panel = makePanel(for: feature)
        panels[feature] = panel
        panel.makeKeyAndOrderFront(nil)
    }

    private static func makePanel(for feature: Feature) -> NSPanel {
        let (view, size): (AnyView, NSSize) = switch feature {
        case .wifiFinder: (AnyView(WiFiFinderView()), NSSize(width: 340, height: 460))
        case .speedTest:  (AnyView(SpeedTestView()),  NSSize(width: 360, height: 480))
        case .traceroute: (AnyView(TracerouteView()), NSSize(width: 600, height: 500))
        case .usage:      (AnyView(UsageView()),       NSSize(width: 340, height: 480))
        case .settings:   (AnyView(PreferencesView()), NSSize(width: 380, height: 300))
        }
        let panel = NSPanel(
            contentRect: NSRect(origin: .zero, size: size),
            styleMask: [.titled, .closable, .fullSizeContentView, .nonactivatingPanel],
            backing: .buffered,
            defer: false
        )
        panel.level = .floating
        panel.titlebarAppearsTransparent = true
        panel.isMovableByWindowBackground = true
        panel.contentViewController = NSHostingController(rootView: view)
        panel.center()
        return panel
    }
}
```

- [ ] **Créer les stubs de vues** (pour que le build passe avant d'implémenter chaque feature)

```bash
cat > Sources/NetCheck/Features/WiFiFinder/WiFiFinderView.swift << 'EOF'
import SwiftUI
struct WiFiFinderView: View { var body: some View { Text("WiFi Finder").padding() } }
EOF

cat > Sources/NetCheck/Features/SpeedTest/SpeedTestView.swift << 'EOF'
import SwiftUI
struct SpeedTestView: View { var body: some View { Text("Speed Test").padding() } }
EOF

cat > Sources/NetCheck/Features/Traceroute/TracerouteView.swift << 'EOF'
import SwiftUI
struct TracerouteView: View { var body: some View { Text("Traceroute").padding() } }
EOF

cat > Sources/NetCheck/Features/Usage/UsageView.swift << 'EOF'
import SwiftUI
struct UsageView: View { var body: some View { Text("Usage").padding() } }
EOF

cat > Sources/NetCheck/Features/Settings/PreferencesView.swift << 'EOF'
import SwiftUI
struct PreferencesView: View { var body: some View { Text("Préférences").padding() } }
EOF
```

- [ ] **Builder et tester manuellement** : l'icône globe apparaît dans la barre de menu, le clic ouvre le popover

```bash
./Scripts/build.sh run
```

- [ ] **Commit**

```bash
git add Sources/NetCheck/
git commit -m "feat: app skeleton — menu bar NSStatusItem + popover + WindowManager"
```

---

## Task 5 : Composants NetCheckUI partagés

**Files:**
- Create: `Sources/NetCheckUI/GlassPanelView.swift`
- Create: `Sources/NetCheckUI/StatusBadge.swift`
- Create: `Sources/NetCheckUI/OrganicBubble.swift`
- Create: `Sources/NetCheckUI/FeatureWindowBackground.swift`

- [ ] **Créer `Sources/NetCheckUI/GlassPanelView.swift`**

```swift
import SwiftUI

public struct GlassPanelView<Content: View>: View {
    let content: Content

    public init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }

    public var body: some View {
        content
            .padding()
            .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 16))
            .glassEffect(in: RoundedRectangle(cornerRadius: 16))
    }
}
```

- [ ] **Créer `Sources/NetCheckUI/StatusBadge.swift`**

```swift
import SwiftUI
import NetCheckCore

public struct StatusBadge: View {
    public let quality: QualityLevel

    public init(quality: QualityLevel) { self.quality = quality }

    public var body: some View {
        HStack(spacing: 4) {
            Circle()
                .fill(color)
                .frame(width: 8, height: 8)
            Text(quality.label)
                .font(.caption.weight(.semibold))
                .foregroundStyle(color)
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(color.opacity(0.12), in: Capsule())
    }

    private var color: Color {
        switch quality {
        case .excellent: return .green
        case .good:      return .blue
        case .fair:      return .orange
        case .poor:      return .red
        }
    }
}
```

- [ ] **Créer `Sources/NetCheckUI/OrganicBubble.swift`**

```swift
import SwiftUI

public struct OrganicBubble: View {
    let size: CGFloat
    let color: Color
    let offset: CGPoint
    @State private var phase: Double = 0

    public init(size: CGFloat, color: Color, offset: CGPoint) {
        self.size = size; self.color = color; self.offset = offset
    }

    public var body: some View {
        Ellipse()
            .fill(color.opacity(0.25))
            .frame(width: size * (1 + 0.05 * sin(phase)),
                   height: size * 0.92 * (1 + 0.04 * cos(phase * 1.3)))
            .offset(x: offset.x + 3 * sin(phase * 0.7),
                    y: offset.y + 4 * cos(phase * 0.5))
            .blur(radius: 1)
            .onAppear {
                withAnimation(.linear(duration: 6).repeatForever(autoreverses: false)) {
                    phase = .pi * 2
                }
            }
    }
}
```

- [ ] **Créer `Sources/NetCheckUI/FeatureWindowBackground.swift`**

```swift
import SwiftUI

public struct FeatureWindowBackground<Content: View>: View {
    let tintColor: Color
    let content: Content

    public init(tintColor: Color = .blue, @ViewBuilder content: () -> Content) {
        self.tintColor = tintColor
        self.content = content()
    }

    public var body: some View {
        ZStack {
            // Fond avec teinte
            Rectangle()
                .fill(.background)
                .overlay(tintColor.opacity(0.06))

            // Bulles organiques décoratives
            OrganicBubble(size: 90,  color: tintColor, offset: CGPoint(x: -80, y: -100))
            OrganicBubble(size: 60,  color: tintColor, offset: CGPoint(x:  90, y: -80))
            OrganicBubble(size: 70,  color: tintColor, offset: CGPoint(x: -60, y:  80))
            OrganicBubble(size: 45,  color: tintColor, offset: CGPoint(x:  80, y:  90))

            content
        }
        .ignoresSafeArea()
    }
}
```

- [ ] **Builder**

```bash
xcodegen generate && xcodebuild -project NetCheck.xcodeproj -scheme NetCheck \
  -configuration Debug -derivedDataPath build CODE_SIGNING_ALLOWED=NO 2>&1 | tail -3
```

- [ ] **Commit**

```bash
git add Sources/NetCheckUI/
git commit -m "feat: composants NetCheckUI — GlassPanelView, StatusBadge, OrganicBubble"
```

---

## Task 6 : WiFiScanner + son Geiger

**Files:**
- Create: `Sources/NetCheckCore/WiFi/WiFiScanner.swift`
- Create: `Sources/NetCheckCore/WiFi/GeigerSoundEngine.swift`
- Create: `Tests/NetCheckCoreTests/WiFiScannerTests.swift`

- [ ] **Créer `Sources/NetCheckCore/WiFi/WiFiScanner.swift`**

```swift
import Foundation
import CoreWLAN

public actor WiFiScanner {
    private var scanTask: Task<Void, Never>?
    private var signalContinuations: [UUID: AsyncStream<WiFiSignal>.Continuation] = [:]

    public init() {}

    public func start() {
        scanTask = Task { [weak self] in
            while !Task.isCancelled {
                if let signal = await self?.currentSignal() {
                    await self?.emit(signal)
                }
                try? await Task.sleep(for: .milliseconds(250))
            }
        }
    }

    public func stop() {
        scanTask?.cancel()
        scanTask = nil
    }

    public var signalStream: AsyncStream<WiFiSignal> {
        AsyncStream { continuation in
            let id = UUID()
            signalContinuations[id] = continuation
            continuation.onTermination = { [weak self] _ in
                Task { await self?.signalContinuations.removeValue(forKey: id) }
            }
        }
    }

    private func currentSignal() -> WiFiSignal? {
        guard let iface = CWWiFiClient.shared().interface() else { return nil }
        let rssi = iface.rssiValue()
        guard rssi != 0 else { return nil }
        return WiFiSignal(rssi: rssi, ssid: iface.ssid())
    }

    private func emit(_ signal: WiFiSignal) {
        for cont in signalContinuations.values { cont.yield(signal) }
    }
}
```

- [ ] **Créer `Sources/NetCheckCore/WiFi/GeigerSoundEngine.swift`**

```swift
import Foundation
import AVFoundation

public final class GeigerSoundEngine: @unchecked Sendable {
    private let engine = AVAudioEngine()
    private let playerNode = AVAudioPlayerNode()
    private var tickTask: Task<Void, Never>?
    private var isRunning = false

    public init() {
        engine.attach(playerNode)
        engine.connect(playerNode, to: engine.mainMixerNode, format: nil)
        try? engine.start()
    }

    public func setSignal(_ signal: WiFiSignal) {
        // Intervalle en ms : 80ms à force=1.0, 2000ms à force=0.0
        let intervalMs = 80 + Int((1 - signal.strength) * 1920)
        restartTicking(intervalMs: intervalMs)
    }

    public func stop() {
        tickTask?.cancel()
        tickTask = nil
        isRunning = false
    }

    private func restartTicking(intervalMs: Int) {
        tickTask?.cancel()
        isRunning = true
        tickTask = Task { [weak self] in
            while !Task.isCancelled, self?.isRunning == true {
                self?.playTick()
                try? await Task.sleep(for: .milliseconds(intervalMs))
            }
        }
    }

    private func playTick() {
        // Génère un court bruit blanc (click)
        let sampleRate = 44100.0
        let format = AVAudioFormat(standardFormatWithSampleRate: sampleRate, channels: 1)!
        let frameCount = AVAudioFrameCount(sampleRate * 0.003) // 3ms
        guard let buffer = AVAudioPCMBuffer(pcmFormat: format, frameCapacity: frameCount) else { return }
        buffer.frameLength = frameCount
        let channelData = buffer.floatChannelData![0]
        for i in 0..<Int(frameCount) {
            let t = Double(i) / sampleRate
            // Click exponentiellement amorti
            channelData[i] = Float(0.6 * exp(-t * 800) * sin(2 * .pi * 1200 * t))
        }
        playerNode.play()
        playerNode.scheduleBuffer(buffer, completionHandler: nil)
    }
}
```

- [ ] **Écrire `Tests/NetCheckCoreTests/WiFiScannerTests.swift`**

```swift
import Testing
@testable import NetCheckCore

@Suite("WiFiScanner")
struct WiFiScannerTests {

    @Test func wifiSignalStrengthBounds() {
        let max = WiFiSignal(rssi: -30, ssid: nil)
        let min = WiFiSignal(rssi: -90, ssid: nil)
        let mid = WiFiSignal(rssi: -60, ssid: nil)
        #expect(max.strength == 1.0)
        #expect(min.strength == 0.0)
        #expect(mid.strength > 0.4 && mid.strength < 0.6)
    }

    @Test func scannerStartStop() async throws {
        let scanner = WiFiScanner()
        await scanner.start()
        try await Task.sleep(for: .milliseconds(300))
        await scanner.stop()
        // Test que le scanner ne crash pas
    }
}
```

- [ ] **Lancer les tests**

```bash
xcodebuild test -project NetCheck.xcodeproj -scheme NetCheckCoreTests \
  -destination 'platform=macOS' 2>&1 | grep -E "(PASS|FAIL|error:)"
```

- [ ] **Commit**

```bash
git add Sources/NetCheckCore/WiFi/ Tests/
git commit -m "feat: WiFiScanner CoreWLAN + GeigerSoundEngine AVAudioEngine"
```

---

## Task 7 : WiFiFinder UI

**Files:**
- Modify: `Sources/NetCheck/Features/WiFiFinder/WiFiFinderView.swift`
- Create: `Sources/NetCheck/Features/WiFiFinder/WiFiFinderViewModel.swift`
- Create: `Sources/NetCheck/Features/WiFiFinder/ConcentricWaves.swift`

- [ ] **Créer `Sources/NetCheck/Features/WiFiFinder/WiFiFinderViewModel.swift`**

```swift
import SwiftUI
import NetCheckCore

@MainActor
@Observable
final class WiFiFinderViewModel {
    private(set) var signal: WiFiSignal = WiFiSignal(rssi: -70, ssid: nil)
    var soundEnabled: Bool = true {
        didSet { soundEnabled ? geigerEngine.setSignal(signal) : geigerEngine.stop() }
    }

    private let scanner = WiFiScanner()
    private let geigerEngine = GeigerSoundEngine()
    private var scanTask: Task<Void, Never>?

    func start() {
        Task { await scanner.start() }
        scanTask = Task {
            for await s in await scanner.signalStream {
                signal = s
                if soundEnabled { geigerEngine.setSignal(s) }
            }
        }
    }

    func stop() {
        scanTask?.cancel()
        Task { await scanner.stop() }
        geigerEngine.stop()
    }

    var tintColor: Color {
        let strength = signal.strength
        if strength > 0.6 { return .blue }
        if strength > 0.3 { return .orange }
        return .red
    }

    var waveDuration: Double {
        // 1.5s signal fort → 4s signal faible
        1.5 + (1 - signal.strength) * 2.5
    }
}
```

- [ ] **Créer `Sources/NetCheck/Features/WiFiFinder/ConcentricWaves.swift`**

```swift
import SwiftUI

struct ConcentricWaves: View {
    let color: Color
    let duration: Double
    @State private var animate = false

    var body: some View {
        ZStack {
            ForEach(0..<5, id: \.self) { i in
                Circle()
                    .stroke(color.opacity(animate ? 0 : 0.6 - Double(i) * 0.1), lineWidth: 1.5)
                    .scaleEffect(animate ? 1.0 + Double(i) * 0.3 : 0.3 + Double(i) * 0.05)
                    .animation(
                        .easeOut(duration: duration)
                        .repeatForever(autoreverses: false)
                        .delay(Double(i) * duration / 5),
                        value: animate
                    )
            }
        }
        .frame(width: 180, height: 180)
        .onAppear { animate = true }
        .onChange(of: duration) { animate = false; DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) { animate = true } }
    }
}
```

- [ ] **Réécrire `Sources/NetCheck/Features/WiFiFinder/WiFiFinderView.swift`**

```swift
import SwiftUI
import NetCheckCore
import NetCheckUI

struct WiFiFinderView: View {
    @State private var vm = WiFiFinderViewModel()

    var body: some View {
        FeatureWindowBackground(tintColor: vm.tintColor) {
            VStack(spacing: 24) {
                // Titre
                Text("WiFi Finder")
                    .font(.title2.bold())
                    .padding(.top, 20)

                // Ondes + icône centrale
                ZStack {
                    ConcentricWaves(color: vm.tintColor, duration: vm.waveDuration)
                    Image(systemName: "antenna.radiowaves.left.and.right")
                        .font(.system(size: 32, weight: .medium))
                        .foregroundStyle(vm.tintColor)
                        .symbolEffect(.pulse)
                }

                // Valeur dBm
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

                // Conseil
                GlassPanelView {
                    HStack {
                        Image(systemName: soundEnabled: vm.soundEnabled ? "speaker.wave.2.fill" : "speaker.slash.fill")
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
```

Note : corriger la syntaxe `soundEnabled:` → `vm.soundEnabled ?` dans le `Image(systemName:)`.

- [ ] **Corriger la typo dans WiFiFinderView** (ligne Image systemName)

```swift
Image(systemName: vm.soundEnabled ? "speaker.wave.2.fill" : "speaker.slash.fill")
```

- [ ] **Builder et tester visuellement** — ouvrir WiFi Finder depuis le menu

```bash
./Scripts/build.sh run
```

- [ ] **Commit**

```bash
git add Sources/NetCheck/Features/WiFiFinder/
git commit -m "feat: WiFiFinder UI — ondes organiques, bulles, son Geiger, dBm temps réel"
```

---

## Task 8 : SpeedTestService

**Files:**
- Create: `Sources/NetCheckCore/SpeedTest/SpeedTestService.swift`
- Create: `Tests/NetCheckCoreTests/SpeedTestServiceTests.swift`

- [ ] **Créer `Sources/NetCheckCore/SpeedTest/SpeedTestService.swift`**

```swift
import Foundation

public actor SpeedTestService {
    public init() {}

    public func run() -> AsyncStream<SpeedTestProgress> {
        AsyncStream { continuation in
            Task {
                let process = Process()
                process.executableURL = URL(fileURLWithPath: "/usr/bin/networkQuality")
                process.arguments = ["-s", "-f", "json-extended"]
                let pipe = Pipe()
                process.standardOutput = pipe
                process.standardError = Pipe()

                pipe.fileHandleForReading.readabilityHandler = { handle in
                    let data = handle.availableData
                    guard !data.isEmpty,
                          let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any]
                    else { return }

                    let dl = (json["dl_throughput"] as? Double ?? 0) / 1_000_000
                    let ul = (json["ul_throughput"] as? Double ?? 0) / 1_000_000
                    let rpm = json["responsiveness"] as? Int ?? 0
                    let done = json["test_progress"] as? Double == 1.0

                    continuation.yield(SpeedTestProgress(
                        downloadMbps: dl, uploadMbps: ul, rpm: rpm, isComplete: done
                    ))
                    if done { continuation.finish() }
                }

                do {
                    try process.run()
                    process.waitUntilExit()
                    continuation.finish()
                } catch {
                    continuation.finish()
                }
            }
        }
    }
}
```

- [ ] **Écrire `Tests/NetCheckCoreTests/SpeedTestServiceTests.swift`**

```swift
import Testing
@testable import NetCheckCore

@Suite("SpeedTestService")
struct SpeedTestServiceTests {

    @Test func progressModelInit() {
        let p = SpeedTestProgress(downloadMbps: 100.5, uploadMbps: 50.2, rpm: 1500, isComplete: false)
        #expect(p.downloadMbps == 100.5)
        #expect(p.uploadMbps == 50.2)
        #expect(p.rpm == 1500)
        #expect(!p.isComplete)
    }
}
```

- [ ] **Lancer les tests**

```bash
xcodebuild test -project NetCheck.xcodeproj -scheme NetCheckCoreTests \
  -destination 'platform=macOS' 2>&1 | grep -E "(PASS|FAIL|error:)"
```

- [ ] **Commit**

```bash
git add Sources/NetCheckCore/SpeedTest/ Tests/
git commit -m "feat: SpeedTestService — networkQuality streaming JSON"
```

---

## Task 9 : SpeedTest UI

**Files:**
- Modify: `Sources/NetCheck/Features/SpeedTest/SpeedTestView.swift`
- Create: `Sources/NetCheck/Features/SpeedTest/SpeedTestViewModel.swift`
- Create: `Sources/NetCheck/Features/SpeedTest/SpeedGauge.swift`

- [ ] **Créer `Sources/NetCheck/Features/SpeedTest/SpeedTestViewModel.swift`**

```swift
import SwiftUI
import NetCheckCore

@MainActor
@Observable
final class SpeedTestViewModel {
    private(set) var download: Double = 0
    private(set) var upload: Double = 0
    private(set) var rpm: Int = 0
    private(set) var isRunning = false
    private(set) var isDone = false

    private let service = SpeedTestService()
    private var testTask: Task<Void, Never>?

    func start() {
        guard !isRunning else { return }
        isRunning = true; isDone = false
        download = 0; upload = 0; rpm = 0
        testTask = Task {
            for await progress in await service.run() {
                download = progress.downloadMbps
                upload   = progress.uploadMbps
                rpm      = progress.rpm
                if progress.isComplete { isDone = true; isRunning = false }
            }
            isRunning = false
        }
    }

    var rpmLabel: String {
        switch rpm {
        case 0:      return "—"
        case ..<400: return "Moyen"
        case ..<1000: return "Bon"
        default:     return "Excellent"
        }
    }
}
```

- [ ] **Créer `Sources/NetCheck/Features/SpeedTest/SpeedGauge.swift`**

```swift
import SwiftUI

struct SpeedGauge: View {
    let value: Double
    let maxValue: Double
    let label: String
    let icon: String
    let color: Color

    var body: some View {
        VStack(spacing: 8) {
            ZStack {
                Circle()
                    .stroke(color.opacity(0.15), lineWidth: 8)
                Circle()
                    .trim(from: 0, to: min(value / maxValue, 1))
                    .stroke(color, style: StrokeStyle(lineWidth: 8, lineCap: .round))
                    .rotationEffect(.degrees(-90))
                    .animation(.easeOut(duration: 0.3), value: value)
                VStack(spacing: 2) {
                    Image(systemName: icon)
                        .font(.caption)
                        .foregroundStyle(color)
                    Text(String(format: "%.0f", value))
                        .font(.title2.monospacedDigit().bold())
                    Text("Mb/s")
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                }
            }
            .frame(width: 120, height: 120)
            Text(label)
                .font(.caption.weight(.medium))
                .foregroundStyle(.secondary)
        }
    }
}
```

- [ ] **Réécrire `Sources/NetCheck/Features/SpeedTest/SpeedTestView.swift`**

```swift
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
```

- [ ] **Builder et tester visuellement**

```bash
./Scripts/build.sh run
```

- [ ] **Commit**

```bash
git add Sources/NetCheck/Features/SpeedTest/
git commit -m "feat: SpeedTest UI — jauges circulaires download/upload + RPM temps réel"
```

---

## Task 10 : TracerouteService + GeoIPService

**Files:**
- Create: `Sources/NetCheckCore/Traceroute/TracerouteService.swift`
- Create: `Sources/NetCheckCore/Traceroute/GeoIPService.swift`
- Create: `Tests/NetCheckCoreTests/TracerouteTests.swift`

- [ ] **Créer `Sources/NetCheckCore/Traceroute/TracerouteService.swift`**

```swift
import Foundation

public actor TracerouteService {
    public var destination: String = "8.8.8.8"
    public init() {}

    public func run() -> AsyncStream<TracerouteHop> {
        AsyncStream { continuation in
            Task {
                let process = Process()
                process.executableURL = URL(fileURLWithPath: "/usr/sbin/traceroute")
                process.arguments = ["-n", "-q", "1", "-w", "2", self.destination]
                let pipe = Pipe()
                process.standardOutput = pipe
                process.standardError = Pipe()

                var hopId = 0
                pipe.fileHandleForReading.readabilityHandler = { handle in
                    let data = handle.availableData
                    guard let line = String(data: data, encoding: .utf8) else { return }
                    for rawLine in line.components(separatedBy: "\n") {
                        if let hop = Self.parse(line: rawLine, id: hopId) {
                            hopId += 1
                            continuation.yield(hop)
                        }
                    }
                }

                do {
                    try process.run()
                    process.waitUntilExit()
                } catch {}
                continuation.finish()
            }
        }
    }

    static func parse(line: String, id: Int) -> TracerouteHop? {
        let trimmed = line.trimmingCharacters(in: .whitespaces)
        guard !trimmed.isEmpty, trimmed.first?.isNumber == true else { return nil }

        // Timeout: "3  * * *"
        if trimmed.contains("* * *") {
            return TracerouteHop(id: id, ip: nil, latencyMs: nil,
                                 city: nil, country: nil, latitude: nil, longitude: nil, asn: nil)
        }

        // Normal: "2  10.0.0.1  8.456 ms"
        let parts = trimmed.components(separatedBy: .whitespaces).filter { !$0.isEmpty }
        guard parts.count >= 3 else { return nil }
        let ip = parts[1]
        let latency = Double(parts[2])
        return TracerouteHop(id: id, ip: ip, latencyMs: latency,
                             city: nil, country: nil, latitude: nil, longitude: nil, asn: nil)
    }
}
```

- [ ] **Créer `Sources/NetCheckCore/Traceroute/GeoIPService.swift`**

```swift
import Foundation

public actor GeoIPService {
    private var cache: [String: TracerouteHop] = [:]
    public init() {}

    public func locate(hop: TracerouteHop) async -> TracerouteHop {
        guard let ip = hop.ip else { return hop }
        if let cached = cache[ip] { return cached }

        guard let url = URL(string: "http://ip-api.com/json/\(ip)?fields=country,city,lat,lon,as") else { return hop }
        guard let (data, _) = try? await URLSession.shared.data(from: url),
              let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any]
        else { return hop }

        let enriched = TracerouteHop(
            id: hop.id, ip: ip,
            latencyMs: hop.latencyMs,
            city: json["city"] as? String,
            country: json["country"] as? String,
            latitude: json["lat"] as? Double,
            longitude: json["lon"] as? Double,
            asn: json["as"] as? String
        )
        cache[ip] = enriched
        return enriched
    }
}
```

- [ ] **Écrire `Tests/NetCheckCoreTests/TracerouteTests.swift`**

```swift
import Testing
@testable import NetCheckCore

@Suite("Traceroute")
struct TracerouteTests {

    @Test func parseNormalHop() {
        let hop = TracerouteService.parse(line: "2  10.0.0.1  8.456 ms", id: 1)
        #expect(hop?.ip == "10.0.0.1")
        #expect(hop?.latencyMs == 8.456)
        #expect(hop?.id == 1)
    }

    @Test func parseTimeout() {
        let hop = TracerouteService.parse(line: "3  * * *", id: 2)
        #expect(hop != nil)
        #expect(hop?.ip == nil)
        #expect(hop?.isTimeout == true)
    }

    @Test func parseHeader() {
        let hop = TracerouteService.parse(line: "traceroute to 8.8.8.8 (8.8.8.8), 64 hops max", id: 0)
        #expect(hop == nil)
    }

    @Test func hopIsTimeout() {
        let hop = TracerouteHop(id: 0, ip: nil, latencyMs: nil,
                                city: nil, country: nil, latitude: nil, longitude: nil, asn: nil)
        #expect(hop.isTimeout)
    }
}
```

- [ ] **Lancer les tests**

```bash
xcodebuild test -project NetCheck.xcodeproj -scheme NetCheckCoreTests \
  -destination 'platform=macOS' 2>&1 | grep -E "(PASS|FAIL|error:)"
```

- [ ] **Commit**

```bash
git add Sources/NetCheckCore/Traceroute/ Tests/
git commit -m "feat: TracerouteService + GeoIPService (ip-api.com)"
```

---

## Task 11 : Traceroute UI (globe 3D)

**Files:**
- Modify: `Sources/NetCheck/Features/Traceroute/TracerouteView.swift`
- Create: `Sources/NetCheck/Features/Traceroute/TracerouteViewModel.swift`
- Create: `Sources/NetCheck/Features/Traceroute/GlobeMapView.swift`
- Create: `Sources/NetCheck/Features/Traceroute/HopListView.swift`

- [ ] **Créer `Sources/NetCheck/Features/Traceroute/TracerouteViewModel.swift`**

```swift
import SwiftUI
import MapKit
import NetCheckCore

@MainActor
@Observable
final class TracerouteViewModel {
    private(set) var hops: [TracerouteHop] = []
    private(set) var activeHopIndex: Int = -1
    private(set) var isRunning = false
    private(set) var cameraPosition = MapCameraPosition.camera(
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

        // Descente : espace → orbital → avion
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

        // Remontée
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
```

- [ ] **Créer `Sources/NetCheck/Features/Traceroute/GlobeMapView.swift`**

```swift
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
            // Tracé de la route
            if coordinates.count >= 2 {
                MapPolyline(coordinates: coordinates)
                    .stroke(.yellow.opacity(0.8), lineWidth: 2)
            }
            // Marqueurs des hops
            ForEach(hops) { hop in
                if let lat = hop.latitude, let lon = hop.longitude {
                    let isActive = hop.id == (activeIndex >= 0 ? hops[min(activeIndex, hops.count-1)].id : -1)
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
```

- [ ] **Créer `Sources/NetCheck/Features/Traceroute/HopListView.swift`**

```swift
import SwiftUI
import NetCheckCore

struct HopListView: View {
    let hops: [TracerouteHop]
    let activeIndex: Int

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(Array(hops.enumerated()), id: \.element.id) { idx, hop in
                    HopChip(hop: hop, isActive: idx == activeIndex)
                }
            }
            .padding(.horizontal)
        }
    }
}

struct HopChip: View {
    let hop: TracerouteHop
    let isActive: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(hop.city ?? (hop.isTimeout ? "Timeout" : hop.ip ?? "?"))
                .font(.caption.weight(isActive ? .bold : .regular))
            if let ms = hop.latencyMs {
                Text(String(format: "%.0f ms", ms))
                    .font(.caption2.monospacedDigit())
                    .foregroundStyle(.secondary)
            }
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 6)
        .background(isActive ? Color.yellow.opacity(0.2) : Color.primary.opacity(0.08),
                    in: RoundedRectangle(cornerRadius: 8))
        .overlay(RoundedRectangle(cornerRadius: 8)
            .stroke(isActive ? Color.yellow : Color.clear, lineWidth: 1))
    }
}
```

- [ ] **Réécrire `Sources/NetCheck/Features/Traceroute/TracerouteView.swift`**

```swift
import SwiftUI
import NetCheckUI

struct TracerouteView: View {
    @State private var vm = TracerouteViewModel()

    var activeHop: (any Identifiable)? {
        guard vm.activeHopIndex >= 0, vm.activeHopIndex < vm.hops.count else { return nil }
        return vm.hops[vm.activeHopIndex]
    }

    var body: some View {
        ZStack(alignment: .bottom) {
            // Globe MapKit plein écran
            GlobeMapView(hops: vm.hops, activeIndex: vm.activeHopIndex,
                         cameraPosition: $vm.cameraPosition)

            VStack(spacing: 8) {
                // Info hop actif
                if vm.activeHopIndex >= 0, vm.activeHopIndex < vm.hops.count {
                    let hop = vm.hops[vm.activeHopIndex]
                    GlassPanelView {
                        HStack {
                            VStack(alignment: .leading, spacing: 2) {
                                Text("Hop \(hop.id + 1) · \(hop.city ?? hop.ip ?? "?")")
                                    .font(.caption.weight(.semibold))
                                if let country = hop.country { Text(country).font(.caption2).foregroundStyle(.secondary) }
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

                // Liste des hops
                HopListView(hops: vm.hops, activeIndex: vm.activeHopIndex)
                    .padding(.vertical, 4)

                // Boutons
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
```

- [ ] **Builder et tester visuellement**

```bash
./Scripts/build.sh run
```

- [ ] **Commit**

```bash
git add Sources/NetCheck/Features/Traceroute/
git commit -m "feat: Traceroute UI — globe MapKit 3D, animation caméra espace→avion par hop"
```

---

## Task 12 : UsageQualityService + Usage UI

**Files:**
- Create: `Sources/NetCheckCore/Usage/UsageQualityService.swift`
- Modify: `Sources/NetCheck/Features/Usage/UsageView.swift`
- Create: `Sources/NetCheck/Features/Usage/UsageViewModel.swift`
- Create: `Tests/NetCheckCoreTests/UsageTests.swift`

- [ ] **Créer `Sources/NetCheckCore/Usage/UsageQualityService.swift`**

```swift
import Foundation

public actor UsageQualityService {
    public init() {}

    public func evaluate() async -> [UsageResult] {
        await withTaskGroup(of: UsageResult.self) { group in
            for profile in UsageProfile.allCases {
                group.addTask { await self.test(profile: profile) }
            }
            var results: [UsageResult] = []
            for await result in group { results.append(result) }
            return results.sorted { $0.profile.rawValue < $1.profile.rawValue }
        }
    }

    private func test(profile: UsageProfile) async -> UsageResult {
        let (host, threshold): (String, Double) = switch profile {
        case .mail:      ("smtp.gmail.com", 150)
        case .workspace: ("docs.google.com", 200)
        case .videoConf: ("zoom.us", 100)
        case .gaming:    ("1.1.1.1", 50)
        }

        let latency = await measureTCPLatency(host: host, port: 443)
        let quality: QualityLevel = switch latency {
        case ..<(threshold * 0.5):  .excellent
        case ..<threshold:           .good
        case ..<(threshold * 1.5):  .fair
        default:                     .poor
        }
        return UsageResult(profile: profile, quality: quality, latencyMs: latency)
    }

    private func measureTCPLatency(host: String, port: Int) async -> Double {
        let process = Process()
        process.executableURL = URL(fileURLWithPath: "/usr/bin/nc")
        process.arguments = ["-z", "-w", "2", host, "\(port)"]
        process.standardOutput = Pipe()
        process.standardError = Pipe()
        let start = Date()
        do {
            try process.run()
            process.waitUntilExit()
            return Date().timeIntervalSince(start) * 1000
        } catch {
            return 999
        }
    }
}
```

- [ ] **Écrire `Tests/NetCheckCoreTests/UsageTests.swift`**

```swift
import Testing
@testable import NetCheckCore

@Suite("UsageQuality")
struct UsageTests {

    @Test func qualityLevelLabels() {
        #expect(QualityLevel.excellent.label == "Excellent")
        #expect(QualityLevel.poor.label == "Mauvais")
    }

    @Test func usageResultInit() {
        let r = UsageResult(profile: .mail, quality: .good, latencyMs: 80)
        #expect(r.profile == .mail)
        #expect(r.latencyMs == 80)
    }
}
```

- [ ] **Créer `Sources/NetCheck/Features/Usage/UsageViewModel.swift`**

```swift
import SwiftUI
import NetCheckCore

@MainActor
@Observable
final class UsageViewModel {
    private(set) var results: [UsageResult] = []
    private(set) var isLoading = false
    private let service = UsageQualityService()

    func refresh() {
        isLoading = true
        Task {
            results = await service.evaluate()
            isLoading = false
        }
    }
}
```

- [ ] **Réécrire `Sources/NetCheck/Features/Usage/UsageView.swift`**

```swift
import SwiftUI
import NetCheckCore
import NetCheckUI

struct UsageView: View {
    @State private var vm = UsageViewModel()

    var body: some View {
        FeatureWindowBackground(tintColor: .indigo) {
            VStack(spacing: 16) {
                Text("Qualité par usage")
                    .font(.title2.bold())
                    .padding(.top, 20)

                if vm.isLoading {
                    ProgressView("Mesure en cours…")
                        .padding(.top, 40)
                } else {
                    VStack(spacing: 10) {
                        ForEach(UsageProfile.allCases, id: \.self) { profile in
                            UsageCard(
                                profile: profile,
                                result: vm.results.first(where: { $0.profile == profile })
                            )
                        }
                    }
                    .padding(.horizontal)
                }

                Spacer()

                Button("Actualiser") { vm.refresh() }
                    .buttonStyle(.borderedProminent)
                    .disabled(vm.isLoading)
                    .padding(.bottom, 20)
            }
        }
        .onAppear { vm.refresh() }
    }
}

struct UsageCard: View {
    let profile: UsageProfile
    let result: UsageResult?

    var body: some View {
        GlassPanelView {
            HStack {
                Image(systemName: profile.icon)
                    .font(.title3)
                    .foregroundStyle(.indigo)
                    .frame(width: 32)
                VStack(alignment: .leading, spacing: 2) {
                    Text(profile.rawValue).font(.subheadline.weight(.semibold))
                    if let ms = result?.latencyMs {
                        Text(String(format: "%.0f ms", ms))
                            .font(.caption2.monospacedDigit())
                            .foregroundStyle(.secondary)
                    }
                }
                Spacer()
                if let result {
                    StatusBadge(quality: result.quality)
                } else {
                    ProgressView().scaleEffect(0.7)
                }
            }
        }
    }
}
```

- [ ] **Lancer les tests, builder, tester visuellement**

```bash
xcodebuild test -project NetCheck.xcodeproj -scheme NetCheckCoreTests \
  -destination 'platform=macOS' 2>&1 | grep -E "(PASS|FAIL|error:)"
./Scripts/build.sh run
```

- [ ] **Commit**

```bash
git add Sources/NetCheckCore/Usage/ Sources/NetCheck/Features/Usage/ Tests/
git commit -m "feat: UsageQualityService + Usage UI — 4 profils qualité avec StatusBadge"
```

---

## Task 13 : Settings / Préférences + intégration StatusMenu live

**Files:**
- Modify: `Sources/NetCheck/Features/Settings/PreferencesView.swift`
- Create: `Sources/NetCheck/Features/Settings/AppSettings.swift`
- Modify: `Sources/NetCheck/Features/StatusMenu/StatusMenuView.swift`

- [ ] **Créer `Sources/NetCheck/Features/Settings/AppSettings.swift`**

```swift
import Foundation
import ServiceManagement

@Observable
final class AppSettings {
    static let shared = AppSettings()

    var launchAtLogin: Bool {
        get { SMAppService.mainApp.status == .enabled }
        set {
            do {
                if newValue { try SMAppService.mainApp.register() }
                else { try SMAppService.mainApp.unregister() }
            } catch { print("SMAppService error: \(error)") }
        }
    }

    @AppStorage("geigerSoundEnabled") var geigerSoundEnabled: Bool = true
    @AppStorage("tracerouteDestination") var tracerouteDestination: String = "8.8.8.8"

    private init() {}
}
```

- [ ] **Réécrire `Sources/NetCheck/Features/Settings/PreferencesView.swift`**

```swift
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
```

- [ ] **Builder et tester**

```bash
./Scripts/build.sh run
```

- [ ] **Commit**

```bash
git add Sources/NetCheck/Features/Settings/
git commit -m "feat: Préférences — SMAppService, son Geiger, destination traceroute, Sparkle updater"
```

---

## Task 14 : Scripts release.sh + Sparkle setup

**Files:**
- Create: `Scripts/release.sh`
- Create: `Scripts/fetch-sparkle-tools.sh`
- Create: `Scripts/make-dmg-background.swift`
- Create: `appcast.xml`

- [ ] **Créer `Scripts/fetch-sparkle-tools.sh`**

```bash
#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
SPARKLE_VERSION="2.9.1"
TOOLS_DIR="$ROOT/.sparkle-tools"

if [ -x "$TOOLS_DIR/bin/sign_update" ]; then
  echo "✓ Sparkle tools déjà présents ($SPARKLE_VERSION)"
  exit 0
fi

echo "→ Téléchargement Sparkle $SPARKLE_VERSION tools…"
mkdir -p "$TOOLS_DIR"
curl -fsSL "https://github.com/sparkle-project/Sparkle/releases/download/$SPARKLE_VERSION/Sparkle-$SPARKLE_VERSION.tar.xz" \
  | tar -xJ -C "$TOOLS_DIR"
echo "✅ Sparkle tools installés dans $TOOLS_DIR"
echo ""
echo "ONE-TIME SETUP : génère tes clés EdDSA :"
echo "  $TOOLS_DIR/bin/generate_keys --account NetCheck"
echo "  → Copie la clé publique dans project.yml (SUPublicEDKey)"
```

```bash
chmod +x Scripts/fetch-sparkle-tools.sh
```

- [ ] **Créer `Scripts/make-dmg-background.swift`**

```swift
#!/usr/bin/env swift
import AppKit

let size = CGSize(width: 540, height: 380)
let image = NSImage(size: size)
image.lockFocus()

// Fond dégradé sombre
let gradient = NSGradient(colors: [
    NSColor(red: 0.05, green: 0.05, blue: 0.12, alpha: 1),
    NSColor(red: 0.08, green: 0.08, blue: 0.18, alpha: 1)
])!
gradient.draw(in: NSRect(origin: .zero, size: size), angle: -45)

// Globe emoji centré à gauche
let para = NSMutableParagraphStyle()
para.alignment = .center
let attrs: [NSAttributedString.Key: Any] = [
    .font: NSFont.systemFont(ofSize: 48),
    .paragraphStyle: para
]
"🌐".draw(in: NSRect(x: 60, y: 130, width: 90, height: 80), withAttributes: attrs)

// Flèche
let arrowAttrs: [NSAttributedString.Key: Any] = [
    .font: NSFont.systemFont(ofSize: 32, weight: .light),
    .foregroundColor: NSColor.white.withAlphaComponent(0.4),
    .paragraphStyle: para
]
"→".draw(in: NSRect(x: 220, y: 140, width: 100, height: 60), withAttributes: arrowAttrs)

// Applications folder icon
"📁".draw(in: NSRect(x: 390, y: 130, width: 90, height: 80), withAttributes: attrs)

image.unlockFocus()

let path = CommandLine.arguments.count > 1 ? CommandLine.arguments[1] : "/tmp/background.png"
let rep = NSBitmapImageRep(data: image.tiffRepresentation!)!
let png = rep.representation(using: .png, properties: [:])!
try! png.write(to: URL(fileURLWithPath: path))
print("✅ DMG background → \(path)")
```

```bash
chmod +x Scripts/make-dmg-background.swift
```

- [ ] **Créer `Scripts/release.sh`** (inspiré MarkdownViewer)

```bash
#!/usr/bin/env bash
# Build Release, codesign, notarise, DMG, Sparkle-sign, appcast.xml
# Usage: ./Scripts/release.sh <version>   e.g. ./Scripts/release.sh 1.0.0
set -euo pipefail

VERSION="${1:?Usage: ./Scripts/release.sh <version>}"
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT"

# Vérif version dans project.yml
if ! grep -q "MARKETING_VERSION: \"$VERSION\"" project.yml; then
  echo "✗ MARKETING_VERSION dans project.yml ne correspond pas à $VERSION" >&2
  grep "MARKETING_VERSION" project.yml | sed 's/^/    /' >&2
  exit 1
fi

SIGNING_IDENTITY="${SIGNING_IDENTITY:-Developer ID Application: Vincent LAURIAT (KFLACS69T9)}"
NOTARY_PROFILE="${NOTARY_PROFILE:-NetCheck-Notary}"

# Build
echo "→ xcodegen generate"
xcodegen generate >/dev/null
echo "→ xcodebuild Release"
xcodebuild -project NetCheck.xcodeproj \
  -scheme NetCheck -configuration Release \
  -derivedDataPath build CODE_SIGNING_ALLOWED=NO build 2>&1 | tail -5

APP="$ROOT/build/Build/Products/Release/NetCheck.app"
[ -d "$APP" ] || { echo "✗ App non trouvée : $APP" >&2; exit 1; }

# Staging sans xattrs
STAGING_DIR="$(mktemp -d)"
STAGING="$STAGING_DIR/NetCheck.app"
echo "→ Staging vers $STAGING_DIR"
ditto --norsrc --noextattr --noacl "$APP" "$STAGING"

codesign_ts() {
  local target="$1"
  for attempt in 1 2 3 4 5; do
    if codesign --force --options runtime --timestamp --sign "$SIGNING_IDENTITY" "$target" 2>&1; then
      return 0
    fi
    [ "$attempt" -lt 5 ] && { echo "  ↻ retry $attempt/5…"; sleep 5; }
  done
  echo "✗ codesign échoué après 5 tentatives : $target" >&2; return 1
}

echo "→ Codesign Sparkle nested binaries"
SPARKLE_FW="$STAGING/Contents/Frameworks/Sparkle.framework"
SPARKLE_VER="$SPARKLE_FW/Versions/B"
codesign_ts "$SPARKLE_VER/Autoupdate"
codesign_ts "$SPARKLE_VER/XPCServices/Downloader.xpc"
codesign_ts "$SPARKLE_VER/XPCServices/Installer.xpc"
codesign_ts "$SPARKLE_VER/Updater.app"
codesign_ts "$SPARKLE_FW"
echo "→ Codesign app"
codesign_ts "$STAGING"
codesign --verify --strict --deep "$STAGING"

# DMG
DMG="$ROOT/NetCheck-$VERSION.dmg"
rm -f "$DMG"
DMG_VOLNAME="NetCheck $VERSION"
DMG_LAYOUT="$STAGING_DIR/dmg-layout"
mkdir -p "$DMG_LAYOUT/.background"
ditto --norsrc --noextattr --noacl "$STAGING" "$DMG_LAYOUT/NetCheck.app"
ln -s /Applications "$DMG_LAYOUT/Applications"
swift "$ROOT/Scripts/make-dmg-background.swift" "$DMG_LAYOUT/.background/background.png" >/dev/null

RW_DMG="$STAGING_DIR/temp.dmg"
hdiutil create -volname "$DMG_VOLNAME" -srcfolder "$DMG_LAYOUT" \
  -fs HFS+ -format UDRW -ov "$RW_DMG" >/dev/null

DMG_MOUNT=$(hdiutil attach -nobrowse -noverify -noautoopen "$RW_DMG" \
  | awk -F '\t' 'END {print $NF}')
osascript <<APPLESCRIPT
tell application "Finder"
    tell disk "$DMG_VOLNAME"
        open
        set current view of container window to icon view
        set toolbar visible of container window to false
        set statusbar visible of container window to false
        set the bounds of container window to {200, 100, 740, 480}
        set view_options to the icon view options of container window
        set arrangement of view_options to not arranged
        set icon size of view_options to 128
        set background picture of view_options to file ".background:background.png"
        set position of item "NetCheck.app" of container window to {140, 200}
        set position of item "Applications" of container window to {400, 200}
        update without registering applications
        delay 1
        close
    end tell
end tell
APPLESCRIPT
sync
hdiutil detach "$DMG_MOUNT" -quiet
hdiutil convert "$RW_DMG" -format UDZO -imagekey zlib-level=9 -ov -o "$DMG" >/dev/null
rm -rf "$STAGING_DIR"

# Notarisation
echo "→ Notarisation Apple…"
xcrun notarytool submit "$DMG" --keychain-profile "$NOTARY_PROFILE" --wait
xcrun stapler staple "$DMG"
xcrun stapler validate "$DMG"

# Sparkle signature + appcast.xml
"$ROOT/Scripts/fetch-sparkle-tools.sh" >/dev/null
SPARKLE_TOOLS="$ROOT/.sparkle-tools"
SPARKLE_SIG_LINE=$("$SPARKLE_TOOLS/bin/sign_update" --account "NetCheck" "$DMG")
BUILD_NUMBER=$(/usr/libexec/PlistBuddy -c "Print :CFBundleVersion" \
  "$ROOT/build/Build/Products/Release/NetCheck.app/Contents/Info.plist")
PUB_DATE=$(date -R)

cat > "$ROOT/appcast.xml" <<APPCAST
<?xml version="1.0" encoding="UTF-8"?>
<rss version="2.0" xmlns:sparkle="http://www.andymatuschak.org/xml-namespaces/sparkle">
  <channel>
    <title>NetCheck</title>
    <link>https://raw.githubusercontent.com/vincentlauriat/NetCheck/main/appcast.xml</link>
    <description>NetCheck release feed</description>
    <language>en</language>
    <item>
      <title>v$VERSION</title>
      <pubDate>$PUB_DATE</pubDate>
      <sparkle:version>$BUILD_NUMBER</sparkle:version>
      <sparkle:shortVersionString>$VERSION</sparkle:shortVersionString>
      <sparkle:minimumSystemVersion>26.0</sparkle:minimumSystemVersion>
      <sparkle:releaseNotesLink>https://github.com/vincentlauriat/NetCheck/releases/tag/v$VERSION</sparkle:releaseNotesLink>
      <enclosure
        url="https://github.com/vincentlauriat/NetCheck/releases/download/v$VERSION/NetCheck-$VERSION.dmg"
        type="application/octet-stream"
        $SPARKLE_SIG_LINE />
    </item>
  </channel>
</rss>
APPCAST

DMG_SIZE=$(ls -lh "$DMG" | awk '{print $5}')
echo ""
echo "✅ NetCheck-$VERSION.dmg ($DMG_SIZE) — signé, notarisé, Sparkle-signé"
echo "✅ appcast.xml mis à jour pour v$VERSION"
echo ""
echo "Étapes suivantes :"
echo "  1. gh release create v$VERSION ./NetCheck-$VERSION.dmg --title \"v$VERSION\""
echo "  2. git add appcast.xml && git commit -m 'docs: appcast v$VERSION' && git push"
```

```bash
chmod +x Scripts/release.sh
```

- [ ] **Créer `appcast.xml` initial**

```xml
<?xml version="1.0" encoding="UTF-8"?>
<rss version="2.0" xmlns:sparkle="http://www.andymatuschak.org/xml-namespaces/sparkle">
  <channel>
    <title>NetCheck</title>
    <link>https://raw.githubusercontent.com/vincentlauriat/NetCheck/main/appcast.xml</link>
    <description>NetCheck release feed</description>
    <language>en</language>
  </channel>
</rss>
```

- [ ] **Setup one-time Sparkle (à faire manuellement, une seule fois)**

```bash
./Scripts/fetch-sparkle-tools.sh
# Puis :
.sparkle-tools/bin/generate_keys --account NetCheck
# → Copier la clé publique affichée dans project.yml (SUPublicEDKey)
# → Relancer xcodegen generate
```

- [ ] **Setup notarytool (une seule fois)**

```bash
xcrun notarytool store-credentials "NetCheck-Notary" \
  --apple-id "vincent.lauriat@gmail.com" \
  --team-id "KFLACS69T9"
```

- [ ] **Commit**

```bash
git add Scripts/ appcast.xml
git commit -m "feat: Scripts build.sh + release.sh + Sparkle setup"
```

---

## Task 15 : README + documentation

**Files:**
- Create: `README.md`
- Create: `ARCHITECTURE.md`
- Create: `CHANGES.md`
- Create: `COMMANDS.md`

- [ ] **Créer `README.md`**

```markdown
# NetCheck

![macOS 26+](https://img.shields.io/badge/macOS-26%2B-blue)
![Swift 6](https://img.shields.io/badge/Swift-6.0-orange)
![License MIT](https://img.shields.io/badge/license-MIT-green)

**NetCheck** is a macOS menu bar app that monitors your internet connectivity in real time.

### Features

- 🌐 **Globe icon** — green / orange / red based on connectivity
- 📡 **WiFi Finder** — Geiger counter style with organic bubbles and waves
- ⚡ **Speed Test** — powered by Apple's `networkQuality` (RPM + download/upload)
- 🗺️ **Traceroute** — animated 3D globe camera from space to each hop
- 📊 **Usage** — quality indicators per use case (mail, workspace, video conf, gaming)
- ⚙️ **Preferences** — launch at login, Sparkle auto-updates

### Installation

Download the latest DMG from [Releases](https://github.com/vincentlauriat/NetCheck/releases).

**Requirements:** macOS 26 or later

### Build from source

```bash
brew install xcodegen
xcodegen generate
./Scripts/build.sh run
```

### Architecture

Three SPM targets: `NetCheckCore` (network logic, no UI), `NetCheckUI` (shared SwiftUI components), `NetCheck` (app assembly). See [ARCHITECTURE.md](ARCHITECTURE.md).

### License

MIT © Vincent Lauriat
```

- [ ] **Créer `ARCHITECTURE.md`** (voir section 3 du design spec — copier/adapter)

- [ ] **Créer `CHANGES.md`**

```markdown
# Changelog

## v1.0.0 — 2026-05-10

- Première version publique
- Menu bar globe vert/orange/rouge
- WiFi Finder (Geiger organique)
- Speed Test (networkQuality)
- Traceroute (globe 3D MapKit)
- Usage (4 profils qualité)
- Préférences + Sparkle
```

- [ ] **Créer `COMMANDS.md`**

```markdown
# Commandes

## Build

```bash
./Scripts/build.sh          # Build Debug
./Scripts/build.sh run      # Build + lancer
./Scripts/release.sh 1.0.0  # Release complète
```

## Tests

```bash
xcodebuild test -project NetCheck.xcodeproj \
  -scheme NetCheckCoreTests -destination 'platform=macOS'
```

## Sparkle (one-time setup)

```bash
./Scripts/fetch-sparkle-tools.sh
.sparkle-tools/bin/generate_keys --account NetCheck
xcrun notarytool store-credentials "NetCheck-Notary" \
  --apple-id "vincent.lauriat@gmail.com" --team-id "KFLACS69T9"
```
```

- [ ] **Commit final**

```bash
git add README.md ARCHITECTURE.md CHANGES.md COMMANDS.md
git commit -m "docs: README, ARCHITECTURE, CHANGES, COMMANDS"
```

---

## Ordre d'exécution recommandé

```
Task 1  → Task 2  → Task 3   # Fondations Core
Task 4  → Task 5             # App skeleton + composants UI
Task 6  → Task 7             # WiFi Finder
Task 8  → Task 9             # Speed Test
Task 10 → Task 11            # Traceroute
Task 12                      # Usage
Task 13                      # Settings
Task 14                      # Scripts release
Task 15                      # Documentation
```

Tasks 6-12 sont **indépendantes entre elles** une fois Task 5 complétée — elles peuvent être développées en parallèle.
