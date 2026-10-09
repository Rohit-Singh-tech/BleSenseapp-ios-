#!/bin/bash
set -e

PROJECT_NAME="BLESense"
SCHEME_NAME="BLESense"
BUILD_DIR="./build"

echo "🚀 Building BLESense for iOS device (ARM64)..."
rm -rf "${BUILD_DIR}"
mkdir -p "${BUILD_DIR}"

xcodebuild \
  -project "${PROJECT_NAME}.xcodeproj" \
  -scheme "${SCHEME_NAME}" \
  -configuration Release \
  -sdk iphoneos \
  -destination "generic/platform=iOS" \
  CODE_SIGNING_ALLOWED=NO \
  CODE_SIGNING_REQUIRED=NO \
  CODE_SIGN_IDENTITY="" \
  build \
  CONFIGURATION_BUILD_DIR="${BUILD_DIR}/Release-iphoneos"

echo "📦 Packaging BLESense.ipa..."
mkdir -p "${BUILD_DIR}/Payload"
cp -R "${BUILD_DIR}/Release-iphoneos/${PROJECT_NAME}.app" "${BUILD_DIR}/Payload/"

cd "${BUILD_DIR}"
zip -qr "${PROJECT_NAME}.ipa" Payload
cd ..

cp "${BUILD_DIR}/${PROJECT_NAME}.ipa" "./${PROJECT_NAME}.ipa"
echo "✅ SUCCESS! Generated ./${PROJECT_NAME}.ipa"
