# Commandes

## Build

```bash
./Scripts/build.sh          # Build Debug
./Scripts/build.sh run      # Build + lancer l'app
./Scripts/release.sh 1.0.0  # Release complète (codesign + notarize + DMG)
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
# → Copier la clé publique dans project.yml (SUPublicEDKey)
# → Relancer xcodegen generate

xcrun notarytool store-credentials "NetCheck-Notary" \
  --apple-id "vincent.lauriat@gmail.com" --team-id "KFLACS69T9"
```

## XcodeGen

```bash
xcodegen generate   # Régénère NetCheck.xcodeproj depuis project.yml
```
