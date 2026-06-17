# IDmission Flutter Plugin — Integration Guide

**Plugin:** `flutter_plugin_identity_sdk`  
**Native SDK version:** 11.1.07.2.23  
**Minimum Flutter:** 3.3.0  
**Minimum Dart:** 3.9.2

---

## Prerequisites

| Tool | Minimum version | Notes |
|------|----------------|-------|
| Flutter | 3.3.0 | Run `flutter --version` to check |
| Dart | 3.9.2 | Bundled with Flutter |
| Android minSdk | 26 (Android 8.0) | Set explicitly in your app |
| Android compileSdk | 36 | |
| Java | 21 | Plugin compiles with Java 21 — JDK 17 will fail |
| Kotlin | 2.1.0+ | |
| Android Gradle Plugin | 8.9.1+ | |
| iOS deployment target | 15.6 | |
| CocoaPods | latest | Run `sudo gem install cocoapods` |
| cocoapods-user-defined-build-types | latest | Run `sudo gem install cocoapods-user-defined-build-types` |

---

## Step 1 — Add the dependency

In your app's `pubspec.yaml`, add the plugin under `dependencies`:

```yaml
dependencies:
  flutter:
    sdk: flutter

  flutter_plugin_identity_sdk:
    git:
      url: https://github.com/Idmission-LLC/SDK2Flutter.git
      ref: v11.1.07.2.23        # use the release tag — do not track main
      path: flutter_plugin_identity_sdk
```

Then run:

```bash
flutter pub get
```

---

## Step 2 — Android setup

### 2a. Set SDK versions and Java compatibility

Open `android/app/build.gradle` (Groovy) or `android/app/build.gradle.kts` (Kotlin DSL) and make the following changes:

**Groovy (`build.gradle`)**
```groovy
android {
    compileSdkVersion 36

    compileOptions {
        sourceCompatibility JavaVersion.VERSION_21
        targetCompatibility JavaVersion.VERSION_21
    }

    kotlinOptions {
        jvmTarget = "21"
    }

    defaultConfig {
        minSdkVersion 26     // Required — plugin uses APIs introduced in API 26
        targetSdkVersion 36
        multiDexEnabled true
        // ...
    }
}
```

**Kotlin DSL (`build.gradle.kts`)**
```kotlin
android {
    compileSdk = 36   // replace flutter.compileSdkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_21
        targetCompatibility = JavaVersion.VERSION_21
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_21.toString()
    }

    defaultConfig {
        minSdk = 26          // replace flutter.minSdkVersion — required for API 26
        targetSdk = 36       // replace flutter.targetSdkVersion
        multiDexEnabled = true
        // ...
    }
}
```

> **Flutter template variables:** `flutter create` generates `compileSdk = flutter.compileSdkVersion`, `minSdk = flutter.minSdkVersion`, and `targetSdk = flutter.targetSdkVersion`. Replace all three with the hardcoded values shown above — the plugin requires exact versions and the Flutter variables may not resolve to the correct values.

> **Why Java 21?** The plugin's Android source (`FlutterPluginIdentitySdkPlugin.java`) is compiled with `sourceCompatibility JavaVersion.VERSION_21`. If your app targets Java 17, Gradle will emit a compatibility error during the merge step.

### 2b. Add the IDmission Maven repository

The native SDK (`idmission-mediumsdk`) is published to IDmission's private GitLab Maven registry. Add the repository to your project-level `build.gradle` or `build.gradle.kts`:

**Project-level `build.gradle` (Groovy)**
```groovy
allprojects {
    repositories {
        google()
        mavenCentral()
        maven {
            url "https://gitlab.idmission.com/api/v4/projects/220/packages/maven"
            name "GitLab"
            credentials(HttpHeaderCredentials) {
                name = "Private-Token"
                value = "WESesyuSD9fQeqNEyig6"
            }
            authentication {
                header(HttpHeaderAuthentication)
            }
        }
        // Required for fingerprint capture
        maven { url 'https://jitpack.io' }
    }
}
```

**Project-level `build.gradle.kts` (Kotlin DSL, Flutter 3.16+)**
```kotlin
allprojects {
    repositories {
        google()
        mavenCentral()
        maven {
            url = uri("https://gitlab.idmission.com/api/v4/projects/220/packages/maven")
            name = "GitLab"
            credentials(HttpHeaderCredentials::class) {
                name = "Private-Token"
                value = "WESesyuSD9fQeqNEyig6"
            }
            authentication {
                create<HttpHeaderAuthentication>("header")
            }
        }
        // Required for fingerprint capture
        maven { url = uri("https://jitpack.io") }
    }
}
```

> **Important — Kotlin DSL only:** Do **not** place the Maven repository inside `dependencyResolutionManagement.repositories` in `settings.gradle.kts`. Flutter's Gradle plugin uses `includeBuild`, which is incompatible with `dependencyResolutionManagement`. The `allprojects { repositories { ... } }` block in `build.gradle.kts` is the correct location for Flutter projects.

### 2c. Enable multidex (if not already)

If your `Application` class does not already extend `MultiDexApplication`, add this to your `AndroidManifest.xml`:

```xml
<application
    android:name="androidx.multidex.MultiDexApplication"
    ...>
```

Or extend it in your custom Application class:

```kotlin
class MyApp : MultiDexApplication() { ... }
```

> **Physical device required:** The IDentity SDK requires a physical Android device — the Android Emulator does not support camera capture and will not run the SDK flows.

---

## Step 3 — iOS setup

### 3a. Install the CocoaPods plugin

The iOS native SDK requires mixed static/dynamic framework linking, which CocoaPods does not support natively. You need the `cocoapods-user-defined-build-types` gem:

```bash
sudo gem install cocoapods-user-defined-build-types
```

### 3b. Create or replace your Podfile

Create `ios/Podfile` if it does not exist (a freshly generated Flutter project does not include one), or replace its entire contents with the following:

```ruby
plugin 'cocoapods-user-defined-build-types'

enable_user_defined_build_types!

platform :ios, '15.6'

ENV['COCOAPODS_DISABLE_STATS'] = 'true'

project 'Runner', {
  'Debug' => :debug,
  'Profile' => :release,
  'Release' => :release,
}

def flutter_root
  generated_xcode_build_settings_path = File.expand_path(
    File.join('..', 'Flutter', 'Generated.xcconfig'), __FILE__
  )
  unless File.exist?(generated_xcode_build_settings_path)
    raise "#{generated_xcode_build_settings_path} must exist. " \
          "Run flutter pub get first."
  end
  File.foreach(generated_xcode_build_settings_path) do |line|
    matches = line.match(/FLUTTER_ROOT\=(.*)/)
    return matches[1].strip if matches
  end
  raise "FLUTTER_ROOT not found in #{generated_xcode_build_settings_path}. " \
        "Try deleting Generated.xcconfig, then run flutter pub get"
end

require File.expand_path(
  File.join('packages', 'flutter_tools', 'bin', 'podhelper'), flutter_root
)

flutter_ios_podfile_setup

target 'Runner' do
  use_modular_headers!

  flutter_install_all_ios_pods File.dirname(File.realpath(__FILE__))

  pod 'IDentityMediumSDK2.0'
  pod 'IDentityMediumModels'
  pod 'GoogleMLKit/TextRecognition',  :build_type => :dynamic_framework
  pod 'GZIP',                         :build_type => :dynamic_framework

  target 'RunnerTests' do
    inherit! :search_paths
  end
end

post_install do |installer|
  installer.pods_project.targets.each do |target|
    flutter_additional_ios_build_settings(target)
  end
end
```

> **Why `use_modular_headers!` instead of `use_frameworks!`?** The IDentity SDK ships as a pre-compiled `.xcframework`. Mixing dynamic and static frameworks in CocoaPods requires per-pod `:build_type` overrides, which the `cocoapods-user-defined-build-types` plugin enables. Using `use_frameworks!` globally causes linker conflicts.

### 3c. Run pod install

```bash
cd ios
LANG=en_US.UTF-8 LC_ALL=en_US.UTF-8 pod install
cd ..
```

This downloads several large frameworks (TensorFlowLite, GoogleMLKit, IDentityMediumSDK). Allow several minutes on a clean install.

> **UTF-8 locale:** The `LANG` and `LC_ALL` prefixes are required if your terminal locale is not already set to UTF-8. Without them, CocoaPods throws `Unicode Normalization not appropriate for ASCII-8BIT` and aborts. Add `export LANG=en_US.UTF-8` to your `~/.zshrc` or `~/.profile` to avoid needing the prefix every time.

### 3d. Add required Info.plist permissions

Open `ios/Runner/Info.plist` and add the following keys. The SDK uses the camera for document and face capture; all three strings are required or the app will crash at runtime on iOS 14+:

```xml
<key>NSCameraUsageDescription</key>
<string>Camera access is required to capture identity documents and verify your face.</string>

<key>NSMicrophoneUsageDescription</key>
<string>Microphone access may be required during identity verification.</string>

<key>NSPhotoLibraryUsageDescription</key>
<string>Photo library access is required to select identity documents for verification.</string>
```

---

## Step 4 — Initialize the SDK

Call `idm_sdk_init` once before invoking any service. It is safe to call from `initState` or after your splash screen.

```dart
import 'package:flutter_plugin_identity_sdk/flutter_plugin_identity_sdk.dart';

await FlutterPluginIdentitySdk.idm_sdk_init(
  'https://kyc.idmission.com/',   // API base URL — provided by IDmission
  'n',                             // debug: 'y' enables verbose logging, 'n' disables it
  'YOUR_ACCESS_TOKEN',             // access token — provided by IDmission
);
```

| Parameter | Type | Description |
|-----------|------|-------------|
| `apiBaseUrl` | `String` | Base URL for IDmission API calls. Provided by IDmission for your environment. |
| `debug` | `String` | `'y'` enables verbose SDK logging. Use `'n'` in production. |
| `accessToken` | `String` | Your IDmission API access token. |

**Return value:** `Future<String?>` — returns a JSON string containing the initialization response, or `null` on failure.

---

## Step 5 — Call identity services

All service calls return `Future<String?>` containing a JSON response string. Call `submit_result()` after a service to submit the captured data.

### Service ID 20 — ID Validation

Captures and validates a government-issued ID document.

```dart
final result = await FlutterPluginIdentitySdk.idm_sdk_serviceID20(
  captureBack,    // 'y' to also capture the back of the ID, 'n' for front only
  clientTraceId,  // your unique integer trace ID for this transaction
);
await FlutterPluginIdentitySdk.submit_result();
```

| Parameter | Type | Description |
|-----------|------|-------------|
| `captureBack` | `String` | `'y'` captures both front and back. `'n'` captures front only. |
| `clientTraceId` | `int` | Your transaction reference number for logging and support. |

---

### Service ID 10 — ID Validation and Face Match

Captures an ID document and performs a liveness face match against the photo on the ID.

```dart
final result = await FlutterPluginIdentitySdk.idm_sdk_serviceID10(
  captureBack,
  clientTraceId,
);
await FlutterPluginIdentitySdk.submit_result();
```

Parameters are identical to Service ID 20.

---

### Service ID 50 — ID Validation and Customer Enrollment

Validates an ID document and enrolls the customer biometric profile.

```dart
final result = await FlutterPluginIdentitySdk.idm_sdk_serviceID50(
  uniqueCustomerNumber,   // your internal integer customer identifier
);
await FlutterPluginIdentitySdk.submit_result();
```

| Parameter | Type | Description |
|-----------|------|-------------|
| `uniqueCustomerNumber` | `int` | Your system's unique identifier for this customer. |

---

### Service ID 175 — Customer Biometric Enrollment

Enrolls or updates a customer's biometric profile without document capture.

```dart
final result = await FlutterPluginIdentitySdk.idm_sdk_serviceID175(
  uniqueCustomerNumber,
);
await FlutterPluginIdentitySdk.submit_result();
```

---

### Service ID 105 — Customer Verification

Verifies a returning customer against their enrolled biometric profile.

```dart
final result = await FlutterPluginIdentitySdk.idm_sdk_serviceID105(
  uniqueCustomerNumber,
);
await FlutterPluginIdentitySdk.submit_result();
```

---

### Service ID 185 — Identify Customer

Identifies an unknown individual against enrolled customer profiles.

```dart
final result = await FlutterPluginIdentitySdk.idm_sdk_serviceID185();
await FlutterPluginIdentitySdk.submit_result();
```

---

### Service ID 660 — Live Face Check

Performs a liveness detection check without document capture.

```dart
final result = await FlutterPluginIdentitySdk.idm_sdk_serviceID660();
await FlutterPluginIdentitySdk.submit_result();
```

---

## Step 6 — Handle the response

Every service returns a JSON string. Wrap calls in try/catch:

```dart
try {
  final String? response = await FlutterPluginIdentitySdk.idm_sdk_serviceID20(
    'y',
    12345,
  );
  await FlutterPluginIdentitySdk.submit_result();

  if (response != null) {
    final data = jsonDecode(response);
    // process data
  }
} catch (e) {
  // handle PlatformException or network error
  print('SDK error: $e');
}
```

---

## Migrating from the zip archive install

If you previously integrated the plugin by downloading a zip from Google Drive, follow these steps to switch to the git-based install:

1. **Remove the copied plugin folder** from your project (the directory you extracted from the zip, typically `flutter_plugin_identity_sdk/`).
2. **Revert your `app/build.gradle`** — remove any lines you copied from the zip's `android_build_gradle` directory. Keep only the changes described in Step 2 of this guide.
3. **Revert your `AndroidManifest.xml`** — remove the `<activity>` declaration for `CallPluginActivity` and any `android:theme` you added to `<application>`. These are now provided automatically by the plugin's own manifest.
4. **Remove copied Java source files** — delete any `.java` files you copied from the zip's `android_java_code` directory.
5. **Add the git dependency** as described in Step 1.
6. Run `flutter pub get`.

---

## Troubleshooting

### `Minimum supported Gradle version is X. Current version is Y`
Update your wrapper in `android/gradle/wrapper/gradle-wrapper.properties`:
```properties
distributionUrl=https\://services.gradle.org/distributions/gradle-8.11-all.zip
```

### `Cannot inline bytecode built with JVM target 21 into bytecode that is being built with JVM target 17`
You have not updated `jvmTarget` to `21`. Apply the change in Step 2a.

### `Manifest merger failed: Attribute application@theme`
Your app's `android/app/src/main/AndroidManifest.xml` declares `android:theme` on `<application>` and conflicts with another library. Resolve by keeping the theme only on the `<activity>` tags and removing it from `<application>`.

### `FAILURE: Build failed with an exception ... Could not resolve com.idmission.sdk2:idmission-mediumsdk`
The GitLab Maven credentials are missing or incorrect. Confirm the `Private-Token` value in your project-level `build.gradle` / `build.gradle.kts` matches the token `WESesyuSD9fQeqNEyig6`.

### `pod install` fails with `Unable to find a specification for 'IDentityMediumSDK2.0'`
Verify CocoaPods can reach trunk: `pod repo update`. If you are behind a proxy, configure CocoaPods proxy settings. Also confirm the `cocoapods-user-defined-build-types` gem is installed (`gem list | grep cocoapods-user`).

### iOS build error: `Undefined symbol` or `framework not found`
Ensure `use_modular_headers!` is set in your Podfile and that `use_frameworks!` is **not** present (commented out). Re-run `pod install --repo-update`.

### Camera / crash on first launch (iOS)
All three `NSCameraUsageDescription`, `NSMicrophoneUsageDescription`, and `NSPhotoLibraryUsageDescription` keys must be present in `Info.plist`. A missing key causes an immediate crash on iOS 14+.

---

## Example app

A working example app is included in the repository at [`flutter_plugin_identity_sdk/example/`](flutter_plugin_identity_sdk/example/). It demonstrates all service calls and shows the full Podfile and build configuration.

To run it:

```bash
cd flutter_plugin_identity_sdk/example
flutter pub get
# Android
flutter run
# iOS (from ios/ directory first)
cd ios && pod install && cd ..
flutter run
```
