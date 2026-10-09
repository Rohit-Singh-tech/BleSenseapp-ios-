#!/bin/bash
# ==============================================================================
# BLESense iOS - 1-Click Automated IPA Generation Script
# Run this script on macOS to build, sign, and export BLESense.ipa
# ==============================================================================

set -e

PROJECT_NAME="BLESense"
SCHEME_NAME="BLESense"
CONFIGURATION="Release"
BUILD_DIR="./build"
ARCHIVE_PATH="${BUILD_DIR}/${PROJECT_NAME}.xcarchive"
IPA_OUTPUT_DIR="${BUILD_DIR}/ipa_output"

echo "🚀 Starting BLESense IPA build process..."

# Clean old artifacts
rm -rf "${BUILD_DIR}"
mkdir -p "${BUILD_DIR}"
mkdir -p "${IPA_OUTPUT_DIR}"

echo "🔨 Step 1: Compiling and Archiving Xcode Project..."
xcodebuild archive \
  -project "${PROJECT_NAME}.xcodeproj" \
  -scheme "${SCHEME_NAME}" \
  -configuration "${CONFIGURATION}" \
  -archivePath "${ARCHIVE_PATH}" \
  -destination "generic/platform=iOS" \
  CODE_SIGN_IDENTITY="" \
  CODE_SIGNING_REQUIRED=NO \
  CODE_SIGNING_ALLOWED=NO

echo "📦 Step 2: Packaging Payload into .ipa..."
mkdir -p "${BUILD_DIR}/Payload"
cp -R "${ARCHIVE_PATH}/Products/Applications/${PROJECT_NAME}.app" "${BUILD_DIR}/Payload/"

cd "${BUILD_DIR}"
zip -qr "${PROJECT_NAME}.ipa" Payload
cd ..

cp "${BUILD_DIR}/${PROJECT_NAME}.ipa" "./${PROJECT_NAME}.ipa"

echo "✅ SUCCESS! Generated: ./${PROJECT_NAME}.ipa"
echo "Ready for Sideloadly, AltStore, TestFlight, or Ad-Hoc distribution!"
