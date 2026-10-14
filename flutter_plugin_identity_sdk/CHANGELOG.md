## 11.1.19

**Android native SDK: 11.1.19.2.10**
**iOS native SDK: 11.1.19.2.2**

* Minimum Flutter raised from 3.3.0 to 3.38.0 and minimum Dart from 3.9.2 to 3.10.0 (`pubspec.yaml` and documentation)

### Android
* Bumped Identity SDK2 native library to 11.1.19.2.10
* Plugin module version in `android/build.gradle` set to `11.1.19.2.10`, the same as the native dependency
* Build tooling upgraded: Android Gradle Plugin 8.9.1 → 8.11.1 and Kotlin 2.1.0 → 2.2.20 (plugin and example app), Gradle 8.12 → 8.14 (example app)
* Example app: `minSdk` is 26 (Android 8.0), the same as the plugin and the native SDK
* Java source/target compatibility and Kotlin `jvmTarget` lowered from 21 to 17 (plugin and example app), the same as the React Native wrapper. JDK 17 or newer can build the plugin

### iOS
* Bumped IDentityMediumSDK2.0 to 11.1.19.2.2
* Removed the `GoogleMLKit/TextRecognition`, `TensorFlowLiteSwift` and `GZIP` dependencies — the iOS SDK no longer needs them
* The `cocoapods-user-defined-build-types` plugin is no longer required
* Fixed service calls (ID Validation, Face Match, etc.) never starting the capture screen, leaving the caller waiting forever, on apps using the UIScene lifecycle

### Flutter wrapper
* iOS: the plugin no longer depends on the sample app's `UserDefaults` helper (removed along with the unused `authenticationURL` value); the API base URL and access token are passed directly to the SDK
* iOS: `idm_sdk_init` now returns `"SDK Successfully Initialized"` on success (previously `"SDK successfully initialized"`), the same text as Android
* `idm_sdk_init` accepts optional named parameters that map to the native SDK's initializer (iOS and Android): `language` (default `'en'`; `'es'`, and on Android `'my'`/`'ar'`), `enableGPS` (true), `geolocationRequired` (false), `isUpdateModelsData` (true) and `enableScreenRecording` (false). Existing calls are unchanged
* iOS: capture services now return the result object exactly as the SDK returns it (e.g. `ValidateIdResult`) as JSON, generated from the object's own properties — nothing is renamed, filtered or masked. `UIImage` values are written as base64 JPEG strings. The plugin no longer returns the full API request
* Example app: **QR-code login** — a *Scan QR* button on the configuration page reads a configuration QR code (Login ID, Password, Client ID, Client Secret, URL), fills in the credentials, selects the matching environment and generates the access token
* Example app: the single screen is now **two pages** — *Identity Flutter* (configuration: credentials, token, SDK options, Initialize SDK) and *Identity Services* (the service buttons and results)
* Example app: the access-token auth URL is now derived from the API base URL with the same table as the native IDentity apps. KYC-UK (`identity.london…`) now uses `https://auth.london.idmission.xyz/` and KYC-US (`identity.virginia…`) uses `https://auth.idmission.com/` (previously `identityauth.*`, which was wrong); the lab API base URL now includes port 9043, like iOS
* Example app: the app bar title is now centered on Android as well as iOS
* Example app: paired credential fields, new option switches, SDK version and model list, and settings persisted after a successful initialization, pretty-printed results with base64 masked for display, and thumbnails of the captured images with a full-screen viewer

## 11.1.13

**Android native SDK: 11.1.13.2.18**
**iOS native SDK: 11.1.13.2.3**

### Android
* Bumped Identity SDK2 native library to 11.1.13.2.18

### iOS
* Bumped IDentityMediumSDK2.0 pods to tag 11.1.13.2.3
* Removed unused pods: FaceDetection, ImageLabeling, OpenSSL-Universal, GZIP
* Removed the `IDentityMediumModels` pod — the SDK downloads its on-device `.tflite` models at runtime, so bundling them was redundant. Cuts ~21 MB from the app.
* Example app build number bumped to 4 (version stays 1.0.2).

## 11.1.7

**Android native SDK: 11.1.07.2.23 — Released 28 April 2026**
**iOS native SDK: 11.1.7.2.4**

### Android
* Added customizable properties for enhanced UI flexibility
* Updated DocumentDetect model with ID back-side prediction for improved document recognition
* Reduced overall SDK package size
* Implemented a timeout timer during capture to streamline user workflows
* Aligned prompt and error messaging on ID and Selfie screens with iOS behaviour
* Added support for separate front and back ID capture flow for improved control and user experience

### iOS
* IDentityMediumSDK2.0 version 11.1.7.2.4

### Flutter wrapper
* Plugin now installable directly via git reference in pubspec.yaml — no zip download required
* Fixed AndroidManifest theme merge: removed app-level theme override from plugin manifest so consumer app themes are no longer affected
* Added integration guide (INTEGRATION_GUIDE.md) covering Android and iOS setup end-to-end
