# Contributing to PhoneAI

Thanks for your interest in the project. Contributions of all kinds are welcome — bug reports, documentation fixes, and code.

## Building from source

Requirements (from the [README](README.md)):

- macOS + Xcode 16 or later
- iOS 17.0 or later
- CocoaPods
- A real device with a developer account (Apple ID)

```bash
git clone https://github.com/tangzhiyin/PhoneAI.git
cd PhoneAI
pod install
```

Open `PhoneAI.xcworkspace` in Xcode and build for a **physical iPhone** (`-destination 'generic/platform=iOS'` when using `xcodebuild`). The iOS Simulator is not a supported build destination: the bundled `Frameworks/piper_plus.xcframework` (as well as `sherpa-onnx.xcframework` and `onnxruntime.xcframework`) ships only an `ios-arm64` device slice, so simulator builds fail to link.

## Filing issues

Please open issues at <https://github.com/tangzhiyin/PhoneAI/issues>. For bugs, include:

- Device model (e.g. iPhone 15 Pro)
- iOS version
- App build number (shown in the app's settings)
- Which model was in use (Gemma 4 E2B / E4B, MiniCPM-V 4.6, or a remote Mac Gateway model)
- Steps to reproduce, and whether LIVE mode or LiveLand was involved

There is a bug report form in the issue tracker that walks through these fields.

## Pull requests

PRs are welcome. For anything beyond a small fix, please open an issue first to discuss the change — the runtime has tight memory and threading constraints on device, and early discussion avoids wasted work. Keep changes focused and describe how you tested them (device model and build configuration).

## Code of conduct

This project follows the [Contributor Covenant](CODE_OF_CONDUCT.md).
