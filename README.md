# OkHi Flutter
The official OkHi Flutter library will enable you to start collecting and verifying your user's addresses.

[Documentation](https://docs.okhi.com/okhi-documentation/code-libraries/flutter-guide)

[API reference](https://pub.dev/documentation/okhi_flutter/latest/)
## Requirements

- **iOS:** the plugin supports iOS 13.0 and later (the native OkHi iOS SDK 1.10.21 requires 13.0).
  - Flutter 3.47 and later require apps to target **iOS 15.0 or later**: the Flutter engine is built for iOS 15.0, and `flutter run`/`flutter build` raise lower deployment targets to 15.0 automatically. On these Flutter versions set:
    - In `ios/Podfile`: `platform :ios, '15.0'`
    - In Xcode: Runner target → Build Settings → `IPHONEOS_DEPLOYMENT_TARGET = 15.0`
  - Apps built with an older Flutter SDK whose engine still supports iOS 13 can target iOS 13.0.
- Swift Package Manager and CocoaPods are both supported on iOS.
