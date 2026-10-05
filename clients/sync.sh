#!/bin/sh
# 把网页版 index.html 同步进 macOS / Android / iOS 三个客户端
set -e
cd "$(dirname "$0")"

mkdir -p android/app/src/main/assets ios/BabyDuck
cp ../index.html macos/index.html
cp ../index.html android/app/src/main/assets/index.html
cp ../index.html ios/BabyDuck/index.html

echo "synced index.html → macos / android / ios ✓"
