#!/usr/bin/env bash
# Archives the iPhone app in Release and uploads it to App Store Connect, or with --export
# only writes the signed .ipa. Signing is automatic: with the App Store Connect API key,
# Xcode creates the distribution certificate and the App Store profiles it needs.
#
#   ASC_KEY_ID=… ASC_ISSUER_ID=… scripts/upload-ios-app.sh [--export]
#
# The key is read from ~/.appstoreconnect/private_keys/AuthKey_<ASC_KEY_ID>.p8, or
# ASC_KEY_PATH. The build number is the commit count, so a later commit uploads a higher
# build; BUILD_NUMBER overrides it. TEAM_ID defaults to Peek's team, OUTPUT_DIR to a
# folder in $TMPDIR.
set -euo pipefail

root=$(cd "$(dirname "$0")/.." && pwd)
destination=upload
[ "${1:-}" = --export ] && destination="export"
: "${ASC_KEY_ID:?Set ASC_KEY_ID to the App Store Connect API key ID}"
: "${ASC_ISSUER_ID:?Set ASC_ISSUER_ID to the issuer ID of the key}"
key=${ASC_KEY_PATH:-$HOME/.appstoreconnect/private_keys/AuthKey_$ASC_KEY_ID.p8}
[ -f "$key" ] || { echo "No API key at $key" >&2; exit 1; }
team=${TEAM_ID:-HGC93X794T}

config=$root/ios/Configuration/Local.xcconfig
setting() { sed -n "s/^$1 *= *//p" "$config" 2>/dev/null | tail -1; }
if [ "$(setting SDT_USE_API)" != YES ] || [ -z "$(setting SDT_SUPABASE_URL)" ]; then
  echo "ios/Configuration/Local.xcconfig must connect the app to the server (ios/README.md)" >&2
  exit 1
fi
if [ "$(setting SDT_GOOGLE_AUTH_ENABLED)" = YES ] && [ "$(setting SDT_APPLE_AUTH_ENABLED)" != YES ]; then
  echo "The App Store takes Google sign-in only with Sign in with Apple: set SDT_APPLE_AUTH_ENABLED = YES" >&2
  exit 1
fi
if [ -n "$(git -C "$root" status --porcelain -- ios)" ]; then
  echo "ios/ has uncommitted changes; the build would not match a commit" >&2
  exit 1
fi

build=${BUILD_NUMBER:-$(git -C "$root" rev-list --count HEAD)}
out=${OUTPUT_DIR:-${TMPDIR:-/tmp}/peek-app-store-$build}
archive=$out/PeekDeliveryTracker.xcarchive
auth=(-allowProvisioningUpdates -authenticationKeyPath "$key"
  -authenticationKeyID "$ASC_KEY_ID" -authenticationKeyIssuerID "$ASC_ISSUER_ID")
mkdir -p "$out"

xcodebuild archive -project "$root/ios/PeekDeliveryTracker.xcodeproj" -scheme PeekDeliveryTracker \
  -configuration Release -destination generic/platform=iOS -archivePath "$archive" \
  "${auth[@]}" DEVELOPMENT_TEAM="$team" CURRENT_PROJECT_VERSION="$build"

cat > "$out/ExportOptions.plist" <<PLIST
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
  <key>method</key><string>app-store-connect</string>
  <key>destination</key><string>$destination</string>
  <key>teamID</key><string>$team</string>
  <key>signingStyle</key><string>automatic</string>
  <key>uploadSymbols</key><true/>
  <key>manageAppVersionAndBuildNumber</key><false/>
</dict>
</plist>
PLIST

xcodebuild -exportArchive -archivePath "$archive" -exportPath "$out/export" \
  -exportOptionsPlist "$out/ExportOptions.plist" "${auth[@]}"

if [ "$destination" = upload ]; then
  echo "Uploaded build $build. App Store Connect emails when it has been processed for TestFlight."
else
  echo "Exported build $build to $out/export"
fi
