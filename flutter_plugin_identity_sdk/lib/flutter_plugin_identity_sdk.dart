
import 'flutter_plugin_identity_sdk_platform_interface.dart';

class FlutterPluginIdentitySdk {
  Future<String?> getPlatformVersion() {
    return FlutterPluginIdentitySdkPlatform.instance.getPlatformVersion();
  }

  static Future<String?> idm_sdk_init(
      String apiBaseUrl, String debug, String accessToken) async {
      return FlutterPluginIdentitySdkPlatform.instance.idm_sdk_init(apiBaseUrl, debug, accessToken);
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
}
