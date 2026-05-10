# NetCheck

![macOS 26+](https://img.shields.io/badge/macOS-26%2B-blue)
![Swift 6](https://img.shields.io/badge/Swift-6.0-orange)
![License MIT](https://img.shields.io/badge/license-MIT-green)

**NetCheck** is a macOS menu bar app that monitors your internet connectivity in real time.

### Features

- 🌐 **Globe icon** — green / orange / red based on connectivity
- 📡 **WiFi Finder** — Geiger counter style with organic bubbles, concentric waves, and sound
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

Three SPM targets:
- `NetCheckCore` — network logic, no UI (actors, async/await)
- `NetCheckUI` — shared SwiftUI components (Liquid Glass, OrganicBubble)
- `NetCheck` — app assembly (NSStatusItem, feature views)

See [ARCHITECTURE.md](ARCHITECTURE.md) for details.

### License

MIT © Vincent Lauriat
