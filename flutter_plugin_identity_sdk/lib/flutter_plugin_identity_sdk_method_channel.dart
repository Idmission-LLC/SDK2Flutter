import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'flutter_plugin_identity_sdk_platform_interface.dart';

/// An implementation of [FlutterPluginIdentitySdkPlatform] that uses method channels.
class MethodChannelFlutterPluginIdentitySdk extends FlutterPluginIdentitySdkPlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel('flutter_plugin_identity_sdk');

  @override
  Future<String?> getPlatformVersion() async {
    final version = await methodChannel.invokeMethod<String>('getPlatformVersion');
    return version;
  }

  @override
  Future<String?> idm_sdk_init(String apiBaseUrl, String accessToken,
      {String language = 'en',
      bool enableGPS = true,
      bool geolocationRequired = false,
      bool isUpdateModelsData = true,
      bool enableScreenRecording = false,
      bool enableDebugMode = false}) async {
    final String? resultData = await methodChannel.invokeMethod('idm_sdk_init', {
      "apiBaseUrl": apiBaseUrl,
      "accessToken": accessToken,
      "language": language,
      "enableGPS": enableGPS,
      "geolocationRequired": geolocationRequired,
      "isUpdateModelsData": isUpdateModelsData,
      "enableScreenRecording": enableScreenRecording,
      "enableDebugMode": enableDebugMode,
    });
    return resultData;
  }

  @override
  Future<String?> idm_sdk_serviceID20(String captureBack, int clientTraceId) async {
    final String? resultData = await methodChannel.invokeMethod('idm_sdk_serviceID20', {"captureBack": captureBack, "clientTraceId": clientTraceId});
    return resultData;
  }

  @override
  Future<String?> idm_sdk_serviceID10(String captureBack, int clientTraceId) async {
    final String? resultData = await methodChannel.invokeMethod('idm_sdk_serviceID10', {"captureBack": captureBack, "clientTraceId": clientTraceId});
    return resultData;
  } 

  @override
   Future<String?> idm_sdk_serviceID50(int uniqueCustomerNumber) async {
    final String? resultData = await methodChannel.invokeMethod('idm_sdk_serviceID50', {"uniqueCustomerNumber": uniqueCustomerNumber});
    return resultData;
  }

  @override
   Future<String?> idm_sdk_serviceID175(int uniqueCustomerNumber) async {
    final String? resultData = await methodChannel.invokeMethod('idm_sdk_serviceID175', {"uniqueCustomerNumber": uniqueCustomerNumber});
    return resultData;
  }

  @override
   Future<String?> idm_sdk_serviceID105(int uniqueCustomerNumber) async {
    final String? resultData = await methodChannel.invokeMethod('idm_sdk_serviceID105', {"uniqueCustomerNumber": uniqueCustomerNumber});
    return resultData;
  }    

  @override
   Future<String?> idm_sdk_serviceID185() async {
    final String? resultData = await methodChannel.invokeMethod('idm_sdk_serviceID185');
    return resultData;
  } 

  @override
   Future<String?> idm_sdk_serviceID660() async {
    final String? resultData = await methodChannel.invokeMethod('idm_sdk_serviceID660');
    return resultData;
  } 

  @override
  Future<String?> submit_result() async {
    final String? resultData = await methodChannel.invokeMethod('submit_result');
    return resultData;
  } 


  @override
  Future<Map<String, dynamic>> getSDKInfo() async {
    final Map<dynamic, dynamic>? info = await methodChannel.invokeMapMethod<dynamic, dynamic>('getSDKInfo');
    return Map<String, dynamic>.from(info ?? const {});
  }

}
