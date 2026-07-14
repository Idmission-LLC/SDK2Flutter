# flutter_plugin_identity_sdk

Flutter plugin wrapping the IDmission Identity SDK for Android and iOS. Supports identity verification, government ID document capture, face match, liveness detection, and biometric enrollment.

## Installation

Add the git dependency to your app's `pubspec.yaml`:

```yaml
dependencies:
  flutter_plugin_identity_sdk:
    git:
      url: https://github.com/Idmission-LLC/SDK2Flutter.git
      ref: v11.1.7
      path: flutter_plugin_identity_sdk
```

```bash
flutter pub get
```

## Quick start

```dart
import 'package:flutter_plugin_identity_sdk/flutter_plugin_identity_sdk.dart';

// 1. Initialise once (e.g. in initState or after splash)
await FlutterPluginIdentitySdk.idm_sdk_init(
  'https://api.idmission.com/',  // API base URL — provided by IDmission
  'n',                            // 'y' enables debug logging
  accessToken,
);

// 2. Call a service
final result = await FlutterPluginIdentitySdk.idm_sdk_serviceID10(
  'y',    // capture back of ID
  12345,  // your clientTraceId
);
await FlutterPluginIdentitySdk.submit_result();
```

## Services

| Method | Service |
|--------|---------|
| `idm_sdk_serviceID20` | ID document validation |
| `idm_sdk_serviceID10` | ID validation + face match |
| `idm_sdk_serviceID50` | ID validation + customer enrollment |
| `idm_sdk_serviceID175` | Biometric enrollment |
| `idm_sdk_serviceID105` | Customer verification |
| `idm_sdk_serviceID185` | Identify customer |
| `idm_sdk_serviceID660` | Live face check |

## Platform requirements

| Requirement | Android | iOS |
|-------------|---------|-----|
| Minimum OS | API 26 (Android 8.0) | iOS 15.6 |
| Language | Java 21 | Swift 5.0 |
| Build tools | AGP 8.9.1+, Kotlin 2.1.0+ | CocoaPods + `cocoapods-user-defined-build-types` |

> For full setup instructions including Maven repository config, Podfile, Info.plist permissions, and troubleshooting, see the [Integration Guide](../INTEGRATION_GUIDE.md).

## License

See [LICENSE](../LICENSE).

