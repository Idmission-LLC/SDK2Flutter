# IDmission Flutter Plugin

![Android](https://img.shields.io/badge/platform-Android-green) ![iOS](https://img.shields.io/badge/platform-iOS-blue) ![Flutter](https://img.shields.io/badge/Flutter-3.3%2B-blue)

Flutter plugin wrapping the **IDmission Identity SDK** for Android and iOS. Provides identity verification, government ID document capture, face match, liveness detection, and biometric enrollment — all via a single Dart API.

## Installation

Add to your `pubspec.yaml`:

```yaml
dependencies:
  flutter_plugin_identity_sdk:
    git:
      url: https://github.com/Idmission-LLC/SDK2Flutter.git
      ref: v11.1.7
      path: flutter_plugin_identity_sdk
```

Then run:

```bash
flutter pub get
```

## Requirements

| Platform | Minimum |
|----------|---------|
| Android | API 26 (Android 8.0), Java 21, AGP 8.9.1+ |
| iOS | iOS 15.6, CocoaPods + `cocoapods-user-defined-build-types` |
| Flutter | 3.3.0 / Dart 3.9.2 |

## Available services

- **ID 20** — ID document validation
- **ID 10** — ID validation + face match
- **ID 50** — ID validation + customer enrollment
- **ID 175** — Biometric enrollment
- **ID 105** — Customer verification
- **ID 185** — Identify customer
- **ID 660** — Live face check

## Documentation

For full Android and iOS setup, SDK initialisation, service usage, and troubleshooting, see the [Integration Guide](INTEGRATION_GUIDE.md).

## Native SDK versions

- Android: `idmission-mediumsdk 11.1.07.2.23`
- iOS: `IDentityMediumSDK2.0 11.1.7.2.4`
