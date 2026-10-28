#!/bin/bash
# Build a SwiftPM executable package into a real, self-contained .app bundle.
# Usage: build-app.sh <package-dir> <executable-name> <display-name> <bundle-id>
set -euo pipefail

PKG_DIR="$1"
EXE_NAME="$2"
DISPLAY_NAME="$3"
BUNDLE_ID="$4"

APP="${EXE_NAME}.app"
OUT_DIR="$(pwd)/dist"

echo "== Building ${EXE_NAME} (release) =="
swift build --package-path "${PKG_DIR}" -c release
BIN_PATH="$(swift build --package-path "${PKG_DIR}" -c release --show-bin-path)/${EXE_NAME}"
test -f "${BIN_PATH}"
file "${BIN_PATH}"

echo "== Assembling ${APP} =="
rm -rf "${APP}"
mkdir -p "${APP}/Contents/MacOS" "${APP}/Contents/Resources"
cp "${BIN_PATH}" "${APP}/Contents/MacOS/${EXE_NAME}"
chmod +x "${APP}/Contents/MacOS/${EXE_NAME}"

cat > "${APP}/Contents/Info.plist" <<PLIST
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>CFBundleName</key>
    <string>${EXE_NAME}</string>
    <key>CFBundleDisplayName</key>
    <string>${DISPLAY_NAME}</string>
    <key>CFBundleIdentifier</key>
    <string>${BUNDLE_ID}</string>
    <key>CFBundleExecutable</key>
    <string>${EXE_NAME}</string>
    <key>CFBundlePackageType</key>
    <string>APPL</string>
    <key>CFBundleVersion</key>
    <string>1</string>
    <key>CFBundleShortVersionString</key>
    <string>1.0.0</string>
    <key>LSMinimumSystemVersion</key>
    <string>13.0</string>
    <key>NSHighResolutionCapable</key>
    <true/>
    <key>CFBundleDevelopmentRegion</key>
    <string>en</string>
</dict>
</plist>
PLIST

echo "== Ad-hoc signing ${APP} =="
codesign --force --deep --sign - "${APP}"
codesign --verify --verbose "${APP}" || true

echo "== Zipping =="
mkdir -p "${OUT_DIR}"
rm -f "${OUT_DIR}/${EXE_NAME}-macOS.zip"
# ditto preserves the bundle exactly as Finder would package it.
ditto -c -k --sequesterRsrc --keepParent "${APP}" "${OUT_DIR}/${EXE_NAME}-macOS.zip"
ls -lh "${OUT_DIR}/${EXE_NAME}-macOS.zip"
echo "DONE ${APP}"
