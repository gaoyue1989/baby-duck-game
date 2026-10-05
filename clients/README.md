# 小黄鸭乐园 · 客户端

| 平台 | 状态 | 构建方式 |
| --- | --- | --- |
| macOS | ✅ 已编译:`../dist/BabyDuck.app` | `./macos/build.sh`(Swift + WKWebView,已实测) |
| Android | 📦 完整工程,待构建 | Android Studio 打开 `android/` 即可 |
| iOS | 📦 完整工程,待构建 | Xcode 打开 `ios/BabyDuck.xcodeproj` 即可 |

三个客户端都是同一个 WebView 壳:加载同一份 `index.html`,并用系统 TTS(Android TextToSpeech / Apple AVSpeechSynthesizer)朗读中文词语,发音比浏览器内置语音更稳定。游戏本身离线运行,不需要网络权限。

改了 `index.html` 之后:先 `./sync.sh` 同步进三个工程,再各自重新构建。

## macOS

```sh
cd clients
./gen-icons.sh     # 首次或改图标后运行
./macos/build.sh
open ../dist/BabyDuck.app
```

产物:`dist/BabyDuck.app`(Ad-hoc 签名,仅本机运行)。要求 macOS 12+。

## Android

1. 安装 Android Studio(Hedgehog 或更新,自带 JDK 17)
2. 打开 `clients/android/`,等待 Gradle 同步完成
3. 插上平板/手机(开启 USB 调试),点 Run ▶;或菜单 Build → Build App Bundle(s)/APK(s) → Build APK(s) 生成 `app-debug.apk` 再传到设备安装

工程要点:`minSdk 26`,无任何第三方依赖,离线运行,沉浸式全屏,旋转不重载。未包含 `gradlew` wrapper jar(不含二进制),Android Studio 会自动补齐;命令行构建需自备 Gradle 8.7 + JDK 17。

## iOS

1. 安装完整 Xcode 16+(当前机器只有命令行工具,无法在本机编译)
2. 打开 `clients/ios/BabyDuck.xcodeproj`
3. Signing & Capabilities 里选择你的开发者 Team
4. 插上 iPhone/iPad,点 Run ▶;正式分发走 Product → Archive

工程用 Xcode 16 的 folder-synchronized 格式(`index.html` 放在 `BabyDuck/` 内,随工程自动打包)。免费个人 Apple ID 也可以真机侧载(7 天有效);上架 App Store 需要付费开发者账号。
