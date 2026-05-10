# NetCheck — Architecture

## Overview

NetCheck is split into three targets to enforce clean separation:

```
NetCheck/
├── Sources/
│   ├── NetCheckCore/          # Network logic — zero UI
│   │   ├── Monitor/           # ConnectivityMonitor, PingService
│   │   ├── WiFi/              # WiFiScanner, GeigerSoundEngine, WiFiSignal
│   │   ├── SpeedTest/         # SpeedTestService, SpeedTestProgress
│   │   ├── Traceroute/        # TracerouteService, GeoIPService, TracerouteHop
│   │   └── Usage/             # UsageQualityService, UsageProfile, QualityLevel
│   ├── NetCheckUI/            # Shared SwiftUI components
│   │   ├── GlassPanelView     # Liquid Glass panel wrapper
│   │   ├── StatusBadge        # Quality indicator badge
│   │   ├── OrganicBubble      # Animated organic ellipse
│   │   └── FeatureWindowBackground  # Tinted background with bubbles
│   └── NetCheck/              # App target — assembly only
│       ├── App/               # NetCheckApp, AppDelegate
│       ├── Features/          # One folder per feature
│       └── Resources/         # Assets.xcassets
├── Tests/
│   └── NetCheckCoreTests/     # Unit tests for Core logic
└── Scripts/
    ├── build.sh               # Debug build
    └── release.sh             # Codesign + notarize + DMG + Sparkle
```

## Key Design Decisions

| Decision | Rationale |
|----------|-----------|
| macOS 26 minimum | Native Liquid Glass APIs |
| XcodeGen + xcodebuild | CLI-only build, no Xcode IDE required |
| `networkQuality` for speed test | Apple-native, same result as System Settings |
| MapKit `.imagery(elevation: .realistic)` | 3D globe with camera animation |
| `ip-api.com` for IP geolocation | Free, 45 req/min, no API key |
| Non-sandboxed | Required for traceroute, CoreWLAN RSSI, networkQuality |
| Sparkle 2.9.1 | EdDSA signatures, proven in production |

## Concurrency

All Core services use Swift 6 actors. ViewModels are `@MainActor @Observable`.
