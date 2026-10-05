#!/bin/sh
# 生成三个平台共用的 App 图标(macOS icns / Android mipmap / iOS appiconset)
set -e
cd "$(dirname "$0")"

# Swift 工具链在这台机器上损坏,图标生成器用 ObjC + clang
ICONGEN=$(mktemp -d)/icongen
clang -fobjc-arc -O -framework Foundation -framework CoreGraphics -framework ImageIO \
  -o "$ICONGEN" icon/make_icon.m
"$ICONGEN" icon/icon-1024.png

# macOS icns
rm -rf icon/AppIcon.iconset
mkdir -p icon/AppIcon.iconset
for s in 16 32 128 256 512; do
  sips -z $s $s icon/icon-1024.png --out icon/AppIcon.iconset/icon_${s}x${s}.png >/dev/null
  d=$((s * 2))
  sips -z $d $d icon/icon-1024.png --out icon/AppIcon.iconset/icon_${s}x${s}@2x.png >/dev/null
done
iconutil -c icns icon/AppIcon.iconset -o icon/AppIcon.icns

# Android mipmap PNG
A=android/app/src/main/res
mkdir -p "$A/mipmap-mdpi" "$A/mipmap-hdpi" "$A/mipmap-xhdpi" "$A/mipmap-xxhdpi" "$A/mipmap-xxxhdpi"
sips -z 48 48   icon/icon-1024.png --out "$A/mipmap-mdpi/ic_launcher.png"    >/dev/null
sips -z 72 72   icon/icon-1024.png --out "$A/mipmap-hdpi/ic_launcher.png"    >/dev/null
sips -z 96 96   icon/icon-1024.png --out "$A/mipmap-xhdpi/ic_launcher.png"   >/dev/null
sips -z 144 144 icon/icon-1024.png --out "$A/mipmap-xxhdpi/ic_launcher.png"  >/dev/null
sips -z 192 192 icon/icon-1024.png --out "$A/mipmap-xxxhdpi/ic_launcher.png" >/dev/null

# iOS 单尺寸 AppIcon
mkdir -p ios/BabyDuck/Assets.xcassets/AppIcon.appiconset
cp icon/icon-1024.png ios/BabyDuck/Assets.xcassets/AppIcon.appiconset/icon1024.png

echo "icons generated ✓"
