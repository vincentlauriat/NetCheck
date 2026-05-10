# NetCheck — Design Spec
**Date:** 2026-05-10  
**Status:** Approved  
**Author:** Vincent Lauriat

---

## 1. Vue d'ensemble

NetCheck est une application macOS menu bar qui indique en permanence l'état de la connexion internet via une icône globe colorée (vert / orange / rouge). Depuis le menu, l'utilisateur accède à cinq outils : WiFi Finder, Speed Test, Traceroute, Usage et Préférences.

L'application est conçue pour être **un exemple de référence** : code propre, architecture exemplaire, build 100 % CLI, notarisée, distribuée via GitHub Releases + Sparkle.

---

## 2. Contraintes techniques

| Contrainte | Valeur |
|-----------|--------|
| macOS minimum | **26.0** (Liquid Glass natif) |
| Build | XcodeGen + xcodebuild CLI — zéro IDE Xcode |
| Design | Apple native · Liquid Glass (`.glassEffect()`, `GlassEffectContainer`) |
| Sandbox | Non-sandboxé (requis pour `traceroute`, `networkQuality`, CoreWLAN) |
| Distribution | GitHub Releases + Sparkle 2.9.1 |
| Signature | Developer ID Application: Vincent LAURIAT (KFLACS69T9) |
| Bundle ID | com.vincent.NetCheck |

---

## 3. Architecture

### 3.1 Structure du projet

```
NetCheck/
├── project.yml                        # XcodeGen — définit les 3 targets
├── Package.swift                      # SPM — résolution des dépendances
├── Sources/
│   ├── NetCheckCore/                  # Logique réseau pure, zéro UI
│   │   ├── Monitor/
│   │   │   ├── ConnectivityMonitor.swift
│   │   │   └── ConnectivityStatus.swift
│   │   ├── WiFi/
│   │   │   └── WiFiScanner.swift
│   │   ├── SpeedTest/
│   │   │   └── SpeedTestService.swift
│   │   ├── Traceroute/
│   │   │   ├── TracerouteService.swift
│   │   │   └── GeoIPService.swift
│   │   └── Usage/
│   │       └── UsageQualityService.swift
│   ├── NetCheckUI/                    # Composants SwiftUI réutilisables
│   │   ├── GlassPanelView.swift
│   │   ├── StatusBadge.swift
│   │   └── OrganicBubble.swift
│   └── NetCheck/                      # App target — assembly
│       ├── App/
│       │   ├── NetCheckApp.swift
│       │   └── AppDelegate.swift
│       ├── Features/
│       │   ├── StatusMenu/
│       │   ├── WiFiFinder/
│       │   ├── SpeedTest/
│       │   ├── Traceroute/
│       │   ├── Usage/
│       │   └── Settings/
│       └── Resources/
│           └── Assets.xcassets
├── Tests/
│   └── NetCheckCoreTests/
├── Scripts/
│   ├── build.sh                       # xcodegen + xcodebuild Debug
│   ├── release.sh                     # codesign + notarize + DMG (inspiré MarkdownViewer)
│   ├── fetch-sparkle-tools.sh
│   └── make-dmg-background.swift
├── appcast.xml                        # Sparkle feed (mis à jour par release.sh)
├── COMMANDS.md                        # Historique des commandes (auto-maintenu)
├── CHANGES.md                         # Changelog (auto-maintenu)
├── ARCHITECTURE.md
└── README.md
```

### 3.2 Targets XcodeGen

- **NetCheckCore** : target library statique. Importe `Network`, `CoreWLAN`, `AVFoundation`. Zéro import SwiftUI/AppKit. Testable via `swift test`.
- **NetCheckUI** : target library statique. Importe uniquement `SwiftUI`. Composants réutilisables agnostiques de la feature.
- **NetCheck** : target application. Importe les deux. Contient uniquement l'assembly, `@main`, `NSStatusItem` et les vues de chaque feature.

---

## 4. NetCheckCore — Services

### 4.1 ConnectivityMonitor

```swift
enum ConnectivityStatus {
    case connected(ping: Int, ssid: String?)   // vert — ping < 100ms
    case degraded(reason: DegradedReason)       // orange
    case offline                                // rouge
}
enum DegradedReason { case highLatency, packetLoss, dnsFailure }
```

Combine trois signaux pour déterminer le statut :
1. `NWPathMonitor` (connectivité de base, Network.framework)
2. Ping ICMP vers `1.1.1.1` et `8.8.8.8` (latence réelle)
3. Résolution DNS de `apple.com` (santé DNS)

Un seul critère défaillant → `degraded`. Tous défaillants → `offline`.

### 4.2 WiFiScanner

- Polling `CWInterface.rssi()` toutes les **250 ms** via `CoreWLAN`
- Publie un `Double` (dBm, -30 à -90)
- Son Geiger : `AVAudioEngine` + oscillateur, tic toutes les **80 ms** à -30 dBm, toutes les **2 s** à -90 dBm

### 4.3 SpeedTestService

- Appelle `networkQuality -s -f json-extended`
- Parse le stdout en streaming (résultats progressifs)
- Publie `SpeedTestProgress` : upload Mb/s, download Mb/s, **RPM** (Responsiveness Per Minute — métrique Apple de qualité perçue)

### 4.4 TracerouteService + GeoIPService

- `TracerouteService` : appelle `/usr/sbin/traceroute -n -q 1 -w 2 8.8.8.8` via `Process`, parse chaque ligne à la volée
- `GeoIPService` : requête `ip-api.com/json/{ip}` (gratuit, 45 req/min, sans clé API) pour obtenir lat/lng, ville, AS de chaque hop
- Publie un `[TracerouteHop]` progressif avec : IP, latence ms, ville, pays, coordonnées GPS

### 4.5 UsageQualityService

Évalue 4 profils en parallèle via ping ICMP + requêtes HTTP :

| Profil | Endpoints | Critères excellent |
|--------|-----------|-------------------|
| Mail | `smtp.gmail.com:587`, `imap.gmail.com:993` | Latence < 150 ms |
| Workspace | `docs.google.com`, `teams.microsoft.com` | Latence < 200 ms, perte < 1 % |
| Vidéo conf | `zoom.us`, `meet.google.com` | Latence < 100 ms, jitter < 30 ms |
| Jeux en ligne | `1.1.1.1` ICMP, ping vers CDN gaming | Latence < 50 ms, jitter < 10 ms |

Retourne `QualityLevel` : `.excellent`, `.good`, `.fair`, `.poor`.

---

## 5. Interface utilisateur

### 5.1 Menu bar principal

- `NSStatusItem` avec icône SF Symbols `globe` colorée
- Un clic → `NSPopover` 300×420 pt avec `GlassEffectContainer`
- Métriques live en en-tête : statut texte, débit, ping
- Entrées de menu : WiFi Finder, Speed Test, Traceroute, Usage, Préférences, Quitter
- Chaque entrée ouvre une `NSPanel` flottante séparée (`.borderless + .fullSizeContentView`, `level: .floating`)

### 5.2 WiFi Finder — 340×460 pt

- Fond qui change de teinte selon le signal : bleu (-30 dBm) → orange (-70 dBm) → rouge (-85 dBm)
- **Bulles flottantes** en arrière-plan : formes `Path` elliptiques légèrement irrégulières, translucides, animées par `TimelineView`
- **Ondes concentriques** : cercles SwiftUI animés avec `scaleEffect` + `opacity` sur `withAnimation(.easeOut.repeatForever)` ; durée 1,5 s (signal fort) à 4 s (signal faible)
- Panel Liquid Glass en bas : valeur dBm, barre de signal, texte conseil
- Bouton toggle son Geiger

### 5.3 Speed Test — 360×480 pt

- Deux jauges circulaires (`Gauge` SwiftUI) download / upload
- Montée progressive en temps réel depuis le stream `networkQuality`
- Valeur RPM affichée en grand avec explication contextuelle
- Bouton "Démarrer" → animation de remplissage + résultats

### 5.4 Traceroute — 600×500 pt

- `Map` MapKit plein écran avec `.mapStyle(.imagery(elevation: .realistic))`
- **Animation caméra par hop** orchestrée par un `Task` Swift :
  1. Globe depuis l'espace (~8 000 km altitude)
  2. Descente orbitale (~800 km)
  3. Vue avion sur le hop (~15 km) → pause 1,5 s avec panel Liquid Glass (IP, latence, ville, AS)
  4. Remontée → hop suivant
- `MapPolyline` animé trace la route au fur et à mesure
- Barre de progression des hops en bas (scrollable)
- Bouton "Rejouer" pour re-animer

### 5.5 Usage — 340×480 pt

- 4 cartes Liquid Glass empilées verticalement
- Chaque carte : icône + nom du profil + `StatusBadge` coloré + latence mesurée
- Bouton "Actualiser" global → relance tous les tests en parallèle

### 5.6 Préférences — 380×300 pt

- **Démarrage automatique** : `SMAppService.mainApp.register()` / `.unregister()`
- Toggle son Geiger WiFi
- Destination traceroute (défaut `8.8.8.8`, modifiable)
- Section "À propos" : version, lien GitHub, bouton "Vérifier les mises à jour" (Sparkle)

---

## 6. Build, signature, notarisation & distribution

### 6.1 Scripts (inspirés MarkdownViewer)

- **`Scripts/build.sh`** : `xcodegen generate` + `xcodebuild Debug`, ouvre l'app en option
- **`Scripts/release.sh <version>`** :
  1. Vérifie `MARKETING_VERSION` dans `project.yml`
  2. `xcodegen generate` → `xcodebuild Release` (`CODE_SIGNING_ALLOWED=NO`)
  3. `ditto --noextattr` vers staging dir (évite xattrs `com.apple.provenance`)
  4. `codesign` avec retry ×5 (timestamp Apple flaky) : Sparkle nested binaries d'abord, puis l'app
  5. Création DMG avec layout Finder AppleScript + fond sombre avec globe
  6. `notarytool submit --wait` (profil keychain `NetCheck-Notary`)
  7. `stapler staple` + `stapler validate`
  8. `sign_update` Sparkle EdDSA → `appcast.xml` mis à jour
  9. Instructions `gh release create`

### 6.2 project.yml (extraits clés)

```yaml
name: NetCheck
options:
  bundleIdPrefix: com.vincent
  deploymentTarget:
    macOS: "26.0"
packages:
  Sparkle:
    url: https://github.com/sparkle-project/Sparkle
    from: "2.9.1"
targets:
  NetCheck:
    type: application
    platform: macOS
    info:
      properties:
        LSUIElement: true
        LSMinimumSystemVersion: "26.0"
        NSLocalNetworkUsageDescription: "NetCheck needs network access to monitor connectivity."
        SUFeedURL: "https://raw.githubusercontent.com/vincentlauriat/NetCheck/main/appcast.xml"
        SUPublicEDKey: "<valeur publique générée une fois via .sparkle-tools/bin/generate_keys, stockée dans project.yml>"
```

### 6.3 Entitlements

```xml
<!-- NetCheck.entitlements (pas de sandbox) -->
<key>com.apple.security.network.client</key><true/>
```

CoreWLAN et `traceroute` requièrent l'absence de sandbox App Store.

### 6.4 Sparkle & appcast.xml

- `appcast.xml` hébergé sur la branche `main`
- `release.sh` le régénère automatiquement à chaque release
- `SUPublicEDKey` dans `Info.plist`, clé privée dans le keychain (`--account NetCheck`)
- Vérification automatique toutes les 24 h (`SUScheduledCheckInterval: 86400`)

---

## 7. GitHub & README

- Repo public : `github.com/vincentlauriat/NetCheck`
- README.md (anglais) : badge CI, GIF animé du globe traceroute, installation (DMG ou Homebrew Cask), architecture diagram, "build from source" (3 commandes), licence MIT
- `.gitignore` : `build/`, `*.dmg`, `.sparkle-tools/Symbols/`, `*.xcodeproj/xcuserdata/`, `.DS_Store`, `.superpowers/`
- Fichiers auto-maintenus : `COMMANDS.md`, `CHANGES.md`, `ARCHITECTURE.md`

---

## 8. Tests

- `NetCheckCoreTests` : tests unitaires sur `ConnectivityStatus`, parsing traceroute, parsing `networkQuality` JSON, `GeoIPService` (mock HTTP)
- Pas de tests UI (SwiftUI Preview suffit pour l'itération design)
- `xcodebuild test -scheme NetCheckCore` ou `swift test` (les deux fonctionnent pour le module Core)

---

## 9. Décisions et rationale

| Décision | Rationale |
|----------|-----------|
| macOS 26 minimum | APIs Liquid Glass natives (`.glassEffect()`), macOS 26 sorti automne 2025 |
| XcodeGen + xcodebuild | Même pattern que MarkdownViewer, CLI pur, pas d'IDE |
| `networkQuality` pour speed test | Natif Apple, même résultat que Réglages Système, zéro dépendance |
| MapKit + `.imagery(elevation: .realistic)` | 100 % natif, globe 3D authentique, animations caméra précises |
| `ip-api.com` pour géolocalisation IPs | Gratuit, 45 req/min, JSON simple, pas de clé |
| Non-sandboxé | Requis pour `traceroute`, CoreWLAN RSSI, `networkQuality` |
| Sparkle 2.9.1 | Même version que MarkdownViewer, EdDSA, éprouvé en production |
