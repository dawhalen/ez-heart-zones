#!/usr/bin/env bash
# Archives a Release build and uploads it to App Store Connect (TestFlight / App Review).
# Uses the Apple ID signed into Xcode → Settings → Accounts for signing and upload.
#
#   scripts/release.sh           archive + upload
#   scripts/release.sh --no-upload   archive + export an .ipa to build/export without uploading
set -euo pipefail

cd "$(dirname "$0")/.."

BUILD_DIR="build"
ARCHIVE_PATH="$BUILD_DIR/EZHeartZones.xcarchive"
# App Store Connect requires a unique, increasing build number for every upload.
BUILD_NUMBER="$(date +%Y%m%d%H%M)"

EXPORT_OPTIONS="scripts/ExportOptions.plist"
if [[ "${1:-}" == "--no-upload" ]]; then
    EXPORT_OPTIONS="$BUILD_DIR/ExportOptions-local.plist"
    mkdir -p "$BUILD_DIR"
    sed 's#<string>upload</string>#<string>export</string>#' scripts/ExportOptions.plist > "$EXPORT_OPTIONS"
fi

tuist generate --no-open

rm -rf "$ARCHIVE_PATH"
xcodebuild archive \
    -workspace EZHeartZones.xcworkspace \
    -scheme EZHeartZones \
    -configuration Release \
    -destination 'generic/platform=iOS' \
    -archivePath "$ARCHIVE_PATH" \
    -allowProvisioningUpdates \
    CURRENT_PROJECT_VERSION="$BUILD_NUMBER"

xcodebuild -exportArchive \
    -archivePath "$ARCHIVE_PATH" \
    -exportOptionsPlist "$EXPORT_OPTIONS" \
    -exportPath "$BUILD_DIR/export" \
    -allowProvisioningUpdates

echo "Done — build $BUILD_NUMBER."
