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
