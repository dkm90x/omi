#!/usr/bin/env bash
set -euo pipefail

# Build the LifeOS-owned Omi iOS app against the self-hosted HTTPS backend.
# Run from app/: bash scripts/build-lifeos-ios.sh

: "${LIFEOS_API_BASE_URL:?Set LIFEOS_API_BASE_URL, e.g. https://omi.example.com/}"
: "${LIFEOS_FIREBASE_PROJECT_ID:?Set LIFEOS_FIREBASE_PROJECT_ID to the Firebase project backing this Omi deployment}"
: "${FIREBASE_SERVICE_ACCOUNT_KEY:?Set FIREBASE_SERVICE_ACCOUNT_KEY to the Firebase service-account JSON path}"

case "$LIFEOS_API_BASE_URL" in
  https://*) ;;
  *) echo "LIFEOS_API_BASE_URL must use https://" >&2; exit 1 ;;
esac

LIFEOS_IOS_BUNDLE_ID="${LIFEOS_IOS_BUNDLE_ID:-com.jordan.lifeos.omi}"
LIFEOS_AUTH_CALLBACK_SCHEME="${LIFEOS_AUTH_CALLBACK_SCHEME:-lifeos-omi}"

if [[ ! -f "$FIREBASE_SERVICE_ACCOUNT_KEY" ]]; then
  echo "Firebase service-account file not found: $FIREBASE_SERVICE_ACCOUNT_KEY" >&2
  exit 1
fi

mkdir -p ios/Config/Prod ios/Runner

dart pub global activate flutterfire_cli
flutterfire config   --platforms=ios   --out=lib/firebase_options_prod.dart   --ios-bundle-id="$LIFEOS_IOS_BUNDLE_ID"   --ios-out=ios/Config/Prod/   --service-account="$FIREBASE_SERVICE_ACCOUNT_KEY"   --project="$LIFEOS_FIREBASE_PROJECT_ID"   --ios-target=Runner   --yes

cp ios/Config/Prod/GoogleService-Info.plist ios/Runner/GoogleService-Info.plist
bash scripts/generate_ios_custom_config.sh ios/Config/Prod/GoogleService-Info.plist ios/Flutter
{
  echo "APP_BUNDLE_IDENTIFIER=$LIFEOS_IOS_BUNDLE_ID"
  echo "AUTH_CALLBACK_SCHEME=$LIFEOS_AUTH_CALLBACK_SCHEME"
} >> ios/Flutter/Custom.xcconfig

# Keep the prod env file pointed at our backend.
python3 - "$LIFEOS_API_BASE_URL" <<'PY'
from pathlib import Path
import sys

path = Path(".env")
api = sys.argv[1]
owned = {
    "API_BASE_URL": api,
    "USE_WEB_AUTH": "true",
    "USE_AUTH_CUSTOM_TOKEN": "true",
}
lines = path.read_text().splitlines() if path.exists() else []
seen = set()
out = []
for line in lines:
    stripped = line.strip()
    key = stripped.split("=", 1)[0].strip() if "=" in stripped and not stripped.startswith("#") else None
    if key in owned:
        if key not in seen:
            out.append(f"{key}={owned[key]}")
            seen.add(key)
    else:
        out.append(line)
for key, value in owned.items():
    if key not in seen:
        out.append(f"{key}={value}")
path.write_text("\n".join(out) + "\n")
PY

flutter pub get
pushd ios >/dev/null
pod install --repo-update
popd >/dev/null
dart run build_runner build

flutter build ios   --flavor prod   --release   --dart-define=OMI_APP_PROFILE=lifeos   --dart-define=OMI_API_BASE_URL="$LIFEOS_API_BASE_URL"   --dart-define=LIFEOS_FIREBASE_PROJECT_ID="$LIFEOS_FIREBASE_PROJECT_ID"

echo
echo "Built: app/build/ios/iphoneos/Runner.app"
echo "Install with: ios-deploy --bundle build/ios/iphoneos/Runner.app"
