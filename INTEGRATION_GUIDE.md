# IDmission Flutter Plugin — Integration Guide

**Plugin:** `flutter_plugin_identity_sdk`  
**Android native SDK:** 11.1.19.2.05  
**iOS native SDK:** 11.1.19.2.2  
**Minimum Flutter:** 3.38.0  
**Minimum Dart:** 3.10.0

---

## Prerequisites

| Tool | Minimum version | Notes |
|------|----------------|-------|
| Flutter | 3.38.0 | Run `flutter --version` to check |
| Dart | 3.10.0 | Bundled with Flutter |
| Android minSdk | 26 (Android 8.0) | Set explicitly in your app |
| Android compileSdk | 36 | |
| Java | 17 | Plugin compiles with Java 17 — use JDK 17 or newer |
| Kotlin | 2.1.0+ | |
| Android Gradle Plugin | 8.9.1+ | |
| iOS deployment target | 15.6 | |
| CocoaPods | latest | Run `sudo gem install cocoapods` |

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
      ref: v11.1.19        # use the release tag — do not track main
      path: flutter_plugin_identity_sdk
```

Then run:

```bash
flutter pub get
```

> **Note on `ref`:** Always pin to a release tag (e.g. `v11.1.19`) rather than a branch name. Tags are immutable, so your build is reproducible. Using `main` or a branch means your app could silently pick up breaking changes on the next `flutter pub get`.

---

## Step 2 — Android setup

### 2a. Set SDK versions and Java compatibility

Open `android/app/build.gradle` (Groovy) or `android/app/build.gradle.kts` (Kotlin DSL) and make the following changes:

**Groovy (`build.gradle`)**
```groovy
android {
    compileSdkVersion 36

    compileOptions {
        sourceCompatibility JavaVersion.VERSION_17
        targetCompatibility JavaVersion.VERSION_17
    }

    kotlinOptions {
        jvmTarget = "17"
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
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_17.toString()
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

> **Why Java 17?** The plugin's Android source (`FlutterPluginIdentitySdkPlugin.java`) is compiled with `sourceCompatibility JavaVersion.VERSION_17`. If your app targets a Java version lower than 17, Gradle will emit a compatibility error during the build.

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

### 3a. Create or replace your Podfile

Create `ios/Podfile` if it does not exist (a freshly generated Flutter project does not include one), or replace its entire contents with the following:

```ruby
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

> **Why `use_modular_headers!` instead of `use_frameworks!`?** The IDentity SDK ships as a pre-compiled `.xcframework`. Using `use_frameworks!` globally causes linker conflicts.

> **Upgrading from 11.1.13 or earlier?** The iOS SDK no longer depends on Google ML Kit, TensorFlow Lite or GZIP. Remove `pod 'GoogleMLKit/TextRecognition'`, `pod 'GZIP'` and the `plugin 'cocoapods-user-defined-build-types'` / `enable_user_defined_build_types!` lines from your Podfile, then re-run `pod install`.

### 3b. Run pod install

```bash
cd ios
LANG=en_US.UTF-8 LC_ALL=en_US.UTF-8 pod install
cd ..
```

This downloads the IDentityMediumSDK frameworks. Allow a few minutes on a clean install.

> **UTF-8 locale:** The `LANG` and `LC_ALL` prefixes are required if your terminal locale is not already set to UTF-8. Without them, CocoaPods throws `Unicode Normalization not appropriate for ASCII-8BIT` and aborts. Add `export LANG=en_US.UTF-8` to your `~/.zshrc` or `~/.profile` to avoid needing the prefix every time.

### 3c. Add required Info.plist permissions

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

Call `idm_sdk_init` once before invoking any service. It is safe to call from `initState` or after your splash screen. You need an access token — see [Getting an access token](#getting-an-access-token) below.

```dart
import 'package:flutter_plugin_identity_sdk/flutter_plugin_identity_sdk.dart';

await FlutterPluginIdentitySdk.idm_sdk_init(
  'https://kyc.idmission.com/',   // API base URL — provided by IDmission
  'YOUR_ACCESS_TOKEN',             // access token — provided by IDmission
  // Optional — these are the defaults:
  language: 'en',                  // 'en' or 'es' (Android also 'my' and 'ar')
  enableGPS: true,                 // capture GPS location with submissions
  geolocationRequired: false,      // block the flow if location access is denied
  isUpdateModelsData: true,        // download the latest SDK models after credential verification
  enableScreenRecording: false,    // allow screen recording / screenshots during capture
  enableDebugMode: false,          // verbose SDK logging; keep false in production
);
```

| Parameter | Type | Description |
|-----------|------|-------------|
| `apiBaseUrl` | `String` | Base URL for IDmission API calls. Provided by IDmission for your environment. |
| `accessToken` | `String` | Your IDmission API access token. |
| `language` | `String` (named, optional) | SDK user-interface language: `'en'` or `'es'` (Android also `'my'` and `'ar'`). Unknown values fall back to `'en'`. Default `'en'`. |
| `enableGPS` | `bool` (named, optional) | Capture the GPS location with submissions. Default `true`. |
| `geolocationRequired` | `bool` (named, optional) | Block the flow if the user denies location access. Default `false`. |
| `isUpdateModelsData` | `bool` (named, optional) | Download the latest SDK models after credential verification. Default `true`. |
| `enableScreenRecording` | `bool` (named, optional) | Allow screen recording / screenshots during capture. Default `false`. |
| `enableDebugMode` | `bool` (named, optional) | Enable verbose SDK logging and debug overlays. Use `false` in production. Default `false`. |

> **Upgrading from earlier versions:** `idm_sdk_init` no longer takes the `debug` string (`'y'` / `'n'`) as its second argument. Remove it and pass `enableDebugMode: true` if you used `'y'`.

**Return value:** `Future<String?>` — `"SDK Successfully Initialized"` on success (the same text on iOS and Android), or `"Error"` / an error message on failure.

### Getting an access token

The plugin does not create access tokens. Your app requests one from IDmission's authentication service and passes it to `idm_sdk_init`. You need the **Login ID**, **Password**, **Client ID** and **Client Secret** that IDmission issued to you.

**Token URL.** Replace the leading `api` in your API base URL's host with `auth`:

| API base URL | Token URL |
|--------------|-----------|
| `https://api.idmission.com/` | `https://auth.idmission.com/auth/realms/identity/protocol/openid-connect/token` |
| `https://apidemo.idmission.com/` | `https://demoauth.idmission.com/auth/realms/identity/protocol/openid-connect/token` |
| `https://apiuat.idmission.com/` | `https://uatauth.idmission.com/auth/realms/identity/protocol/openid-connect/token` |

For any other environment, use the token URL provided by IDmission.

**Request.** `POST` to the token URL with `Content-Type: application/x-www-form-urlencoded` and these fields:

| Field | Value |
|-------|-------|
| `grant_type` | `password` |
| `client_id` | Your Client ID |
| `client_secret` | Your Client Secret |
| `username` | Your Login ID |
| `password` | Your Password |
| `scope` | `api_access` |

```bash
curl -X POST 'https://auth.idmission.com/auth/realms/identity/protocol/openid-connect/token' \
  -H 'Content-Type: application/x-www-form-urlencoded' \
  --data-urlencode 'grant_type=password' \
  --data-urlencode 'client_id=YOUR_CLIENT_ID' \
  --data-urlencode 'client_secret=YOUR_CLIENT_SECRET' \
  --data-urlencode 'username=YOUR_LOGIN_ID' \
  --data-urlencode 'password=YOUR_PASSWORD' \
  --data-urlencode 'scope=api_access'
```

The JSON response contains the token in `access_token`. If the request fails, the response contains `error` and `error_description`.

```dart
import 'dart:convert';
import 'dart:io';

Future<String> fetchAccessToken(String tokenUrl, Map<String, String> credentials) async {
  final body = {
    'grant_type': 'password',
    'scope': 'api_access',
    ...credentials, // client_id, client_secret, username, password
  }.entries
      .map((e) => '${Uri.encodeQueryComponent(e.key)}=${Uri.encodeQueryComponent(e.value)}')
      .join('&');

  final client = HttpClient();
  final request = await client.postUrl(Uri.parse(tokenUrl));
  request.headers.set(HttpHeaders.contentTypeHeader, 'application/x-www-form-urlencoded');
  request.add(utf8.encode(body));
  final response = await request.close();
  final json = jsonDecode(await response.transform(utf8.decoder).join());
  client.close();

  final token = json['access_token'];
  if (token == null) throw json['error_description'] ?? json['error'] ?? 'Token request failed';
  return token as String;
}
```

> **Security:** do not ship the Client Secret or the user's password inside a production app. Request the token from your own backend, or have the user enter or scan the credentials at run time, and pass only the resulting `access_token` to the SDK. The `example/` app fetches the token on the device for demonstration only.

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

### `Cannot inline bytecode built with JVM target 17 into bytecode that is being built with JVM target 1.8`
You have not updated `jvmTarget` to `17`. Apply the change in Step 2a.

### `Manifest merger failed: Attribute application@theme`
Your app's `android/app/src/main/AndroidManifest.xml` declares `android:theme` on `<application>` and conflicts with another library. Resolve by keeping the theme only on the `<activity>` tags and removing it from `<application>`.

### `FAILURE: Build failed with an exception ... Could not resolve com.idmission.sdk2:idmission-mediumsdk`
The GitLab Maven credentials are missing or incorrect. Confirm the `Private-Token` value in your project-level `build.gradle` / `build.gradle.kts` matches the token `WESesyuSD9fQeqNEyig6`.

### `pod install` fails with `Unable to find a specification for 'IDentityMediumSDK2.0'`
Verify CocoaPods can reach trunk: `pod repo update`. If you are behind a proxy, configure CocoaPods proxy settings.

### iOS build error: `Undefined symbol` or `framework not found`
Ensure `use_modular_headers!` is set in your Podfile and that `use_frameworks!` is **not** present (commented out). Re-run `pod install --repo-update`, then clean the build folder in Xcode (**Product → Clean Build Folder**) and rebuild.

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
