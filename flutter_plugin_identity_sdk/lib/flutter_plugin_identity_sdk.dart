import 'dart:async';

import 'package:flutter/services.dart';

class FlutterPluginIdentitySdk {
  static const MethodChannel _channel =
      MethodChannel('flutter_plugin_identity_sdk');

  static Future<String?> get platformVersion async {
    final String? version = await _channel.invokeMethod('getPlatformVersion');
    return version;
  }

  static Future<String?> idm_sdk_init(
      String apiBaseUrl, String debug, String accessToken) async {
    final String? resultData = await _channel.invokeMethod(
        'idm_sdk_init', {"apiBaseUrl": apiBaseUrl, "debug": debug, "accessToken": accessToken});
    return resultData;
  }

  static Future<String?> idm_sdk_serviceID20(
      String captureBack, int clientTraceId) async {
    final String? resultData = await _channel.invokeMethod(
        'idm_sdk_serviceID20',
        {"captureBack": captureBack, "clientTraceId": clientTraceId});
    return resultData;
  }

  static Future<String?> idm_sdk_serviceID10(
      String captureBack, int clientTraceId) async {
    final String? resultData = await _channel.invokeMethod(
        'idm_sdk_serviceID10',
        {"captureBack": captureBack, "clientTraceId": clientTraceId});
    return resultData;
  }

  static Future<String?> idm_sdk_serviceID50(int uniqueCustomerNumber) async {
    final String? resultData = await _channel.invokeMethod(
        'idm_sdk_serviceID50', {"uniqueCustomerNumber": uniqueCustomerNumber});
    return resultData;
  }

  static Future<String?> idm_sdk_serviceID175(int uniqueCustomerNumber) async {
    final String? resultData = await _channel.invokeMethod(
        'idm_sdk_serviceID175', {"uniqueCustomerNumber": uniqueCustomerNumber});
    return resultData;
  }

  static Future<String?> idm_sdk_serviceID105(int uniqueCustomerNumber) async {
    final String? resultData = await _channel.invokeMethod(
        'idm_sdk_serviceID105', {"uniqueCustomerNumber": uniqueCustomerNumber});
    return resultData;
  }

  static Future<String?> idm_sdk_serviceID185() async {
    final String? resultData =
        await _channel.invokeMethod('idm_sdk_serviceID185');
    return resultData;
  }

  static Future<String?> idm_sdk_serviceID660() async {
    final String? resultData =
        await _channel.invokeMethod('idm_sdk_serviceID660');
    return resultData;
  }

  static Future<String?> submit_result() async {
    final String? resultData = await _channel.invokeMethod('submit_result');
    return resultData;
  }
}
