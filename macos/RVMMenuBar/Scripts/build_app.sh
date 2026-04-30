#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PACKAGE_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"
REPO_DIR="$(cd "${PACKAGE_DIR}/../.." && pwd)"
APP_DIR="${PACKAGE_DIR}/.build/RVMMenuBar.app"
MODEL_NAME="rvm_mobilenetv3_1920x1080_s0.25_fp16"
MODEL_PATH="${REPO_DIR}/models/${MODEL_NAME}.mlmodel"

swift build -c release --package-path "${PACKAGE_DIR}"

rm -rf "${APP_DIR}"
mkdir -p "${APP_DIR}/Contents/MacOS"
mkdir -p "${APP_DIR}/Contents/Resources"

cp "${PACKAGE_DIR}/.build/release/RVMMenuBar" "${APP_DIR}/Contents/MacOS/RVMMenuBar"
xcrun coremlcompiler compile "${MODEL_PATH}" "${APP_DIR}/Contents/Resources"

cat > "${APP_DIR}/Contents/Info.plist" <<PLIST
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>CFBundleDevelopmentRegion</key>
    <string>en</string>
    <key>CFBundleExecutable</key>
    <string>RVMMenuBar</string>
    <key>CFBundleIdentifier</key>
    <string>dev.local.RVMMenuBar</string>
    <key>CFBundleInfoDictionaryVersion</key>
    <string>6.0</string>
    <key>CFBundleName</key>
    <string>RVM Menu Bar</string>
    <key>CFBundlePackageType</key>
    <string>APPL</string>
    <key>CFBundleShortVersionString</key>
    <string>0.1.0</string>
    <key>CFBundleVersion</key>
    <string>1</string>
    <key>LSMinimumSystemVersion</key>
    <string>13.0</string>
    <key>LSUIElement</key>
    <true/>
    <key>NSCameraUsageDescription</key>
    <string>RVM Menu Bar uses the camera to run local CoreML matting and show a live preview.</string>
    <key>NSHighResolutionCapable</key>
    <true/>
</dict>
</plist>
PLIST

codesign --force --sign - "${APP_DIR}" >/dev/null

echo "${APP_DIR}"
