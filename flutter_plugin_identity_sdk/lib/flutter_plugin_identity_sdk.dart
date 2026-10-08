
import 'flutter_plugin_identity_sdk_platform_interface.dart';

class FlutterPluginIdentitySdk {
  /// Returns the host OS version. This comes from the Flutter plugin template
  /// and is not part of the IDmission API.
  @Deprecated('Not part of the IDmission API; will be removed in a future release.')
  Future<String?> getPlatformVersion() {
    return FlutterPluginIdentitySdkPlatform.instance.getPlatformVersion();
  }

  /// Initializes the SDK. Call once before any service.
  ///
  /// [debug] is `'y'` to enable verbose SDK logging and debug overlays, or
  /// `'n'` to disable it; use `'n'` in production. The positional parameters
  /// are the same as in earlier releases, so existing calls keep working.
  ///
  /// Optional named parameters (defaults in brackets):
  /// - [language] SDK user-interface language, `'en'` or `'es'` (Android also
  ///   `'my'` and `'ar'`) ['en']
  /// - [enableGPS] capture the GPS location with submissions [true]
  /// - [geolocationRequired] block the flow if location access is denied [false]
  /// - [isUpdateModelsData] download the latest SDK models after credential
  ///   verification [true]
  /// - [enableScreenRecording] allow screen recording / screenshots during
  ///   capture [false]
  static Future<String?> idm_sdk_init(
      String apiBaseUrl, String debug, String accessToken,
      {String language = 'en',
      bool enableGPS = true,
      bool geolocationRequired = false,
      bool isUpdateModelsData = true,
      bool enableScreenRecording = false}) async {
      return FlutterPluginIdentitySdkPlatform.instance.idm_sdk_init(apiBaseUrl, accessToken,
          language: language,
          enableGPS: enableGPS,
          geolocationRequired: geolocationRequired,
          isUpdateModelsData: isUpdateModelsData,
          enableScreenRecording: enableScreenRecording,
          // Same check as the earlier releases: any value containing 'y'.
          enableDebugMode: debug.contains('y'));
  }

  static Future<String?> idm_sdk_serviceID20(
      String captureBack, int clientTraceId) async {
    return FlutterPluginIdentitySdkPlatform.instance.idm_sdk_serviceID20(captureBack, clientTraceId);
  }

  static Future<String?> idm_sdk_serviceID10(
      String captureBack, int clientTraceId) async {
    return FlutterPluginIdentitySdkPlatform.instance.idm_sdk_serviceID10(captureBack, clientTraceId);
  }

  static Future<String?> idm_sdk_serviceID50(int uniqueCustomerNumber) async {
    return FlutterPluginIdentitySdkPlatform.instance.idm_sdk_serviceID50(uniqueCustomerNumber);
  }

  static Future<String?> idm_sdk_serviceID175(int uniqueCustomerNumber) async {
    return FlutterPluginIdentitySdkPlatform.instance.idm_sdk_serviceID175(uniqueCustomerNumber);
  }

  static Future<String?> idm_sdk_serviceID105(int uniqueCustomerNumber) async {
    return FlutterPluginIdentitySdkPlatform.instance.idm_sdk_serviceID105(uniqueCustomerNumber);
  }

  static Future<String?> idm_sdk_serviceID185() async {
    return FlutterPluginIdentitySdkPlatform.instance.idm_sdk_serviceID185();
  }

  static Future<String?> idm_sdk_serviceID660() async {
    return FlutterPluginIdentitySdkPlatform.instance.idm_sdk_serviceID660();
  }

  static Future<String?> submit_result() async {
    return FlutterPluginIdentitySdkPlatform.instance.submit_result();
  }


  /// Returns `{version: String, models: [{name, value}, ...]}`. The `models`
  /// list is empty until the SDK has been initialized.
  static Future<Map<String, dynamic>> getSDKInfo() {
    return FlutterPluginIdentitySdkPlatform.instance.getSDKInfo();
  }

}
