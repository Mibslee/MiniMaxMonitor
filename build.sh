#!/bin/bash
# MiniMaxMonitor — 一键打包 DMG 脚本
# 用法: ./build.sh [版本号]  例: ./build.sh 1.0.1
set -e

VERSION=${1:-"1.0.0"}
APP_NAME="MiniMaxMonitor"
DMG_TITLE="MiniMax Monitor"
BUILD_DIR="build"
APP_PATH="$BUILD_DIR/Build/Products/Release/$APP_NAME.app"
DMG_OUT="$BUILD_DIR/$APP_NAME-$VERSION.dmg"

echo "▶ Building $APP_NAME $VERSION..."

xcodebuild \
  -project "$APP_NAME.xcodeproj" \
  -scheme "$APP_NAME" \
  -configuration Release \
  -derivedDataPath "$BUILD_DIR" \
  build

echo "▶ Creating DMG..."

rm -f "$DMG_OUT"

create-dmg \
  --volname "$DMG_TITLE" \
  --volicon "Assets.xcassets/AppIcon.appiconset/AppIcon-512.png" \
  --window-pos 200 120 \
  --window-size 600 400 \
  --icon-size 100 \
  --icon "$APP_NAME.app" 160 185 \
  --hide-extension "$APP_NAME.app" \
  --app-drop-link 430 185 \
  --no-internet-enable \
  "$DMG_OUT" \
  "$APP_PATH"

echo ""
echo "✅ Done: $DMG_OUT ($(du -sh "$DMG_OUT" | cut -f1))"
echo ""
echo "提示: 如需公证 (notarize)，运行以下命令："
echo "  xcrun notarytool submit \"$DMG_OUT\" \\"
echo "    --apple-id YOUR_APPLE_ID \\"
echo "    --team-id YOUR_TEAM_ID \\"
echo "    --password YOUR_APP_SPECIFIC_PASSWORD \\"
echo "    --wait"
echo "  xcrun stapler staple \"$DMG_OUT\""
