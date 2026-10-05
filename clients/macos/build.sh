#!/bin/sh
# 编译 macOS 客户端:输出 ../dist/BabyDuck.app(用 clang,不依赖 Swift 工具链)
set -e
cd "$(dirname "$0")"

APP=../../dist/BabyDuck.app
mkdir -p "$APP/Contents/MacOS" "$APP/Contents/Resources"
cp Info.plist "$APP/Contents/Info.plist"
cp ../../index.html "$APP/Contents/Resources/index.html"
[ -f ../icon/AppIcon.icns ] && cp ../icon/AppIcon.icns "$APP/Contents/Resources/AppIcon.icns"

clang -fobjc-arc -O -mmacosx-version-min=12.0 \
  -framework Cocoa -framework WebKit -framework AVFoundation \
  -o "$APP/Contents/MacOS/BabyDuck" BabyDuck.m

codesign --force -s - "$APP"
echo "built: $(cd "$APP" && pwd)"
