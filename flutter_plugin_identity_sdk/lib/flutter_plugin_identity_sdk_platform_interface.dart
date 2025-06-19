import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'flutter_plugin_identity_sdk_method_channel.dart';

abstract class FlutterPluginIdentitySdkPlatform extends PlatformInterface {
  /// Constructs a FlutterPluginIdentitySdkPlatform.
  FlutterPluginIdentitySdkPlatform() : super(token: _token);

  static final Object _token = Object();

  static FlutterPluginIdentitySdkPlatform _instance = MethodChannelFlutterPluginIdentitySdk();

  /// The default instance of [FlutterPluginIdentitySdkPlatform] to use.
  ///
  /// Defaults to [MethodChannelFlutterPluginIdentitySdk].
  static FlutterPluginIdentitySdkPlatform get instance => _instance;

  /// Platform-specific implementations should set this with their own
  /// platform-specific class that extends [FlutterPluginIdentitySdkPlatform] when
  /// they register themselves.
  static set instance(FlutterPluginIdentitySdkPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  Future<String?> getPlatformVersion() {
    throw UnimplementedError('platformVersion() has not been implemented.');
  }

  Future<String?> idm_sdk_init(String apiBaseUrl, String debug, String accessToken) async {
throw UnimplementedError('platformVersion() has not been implemented.');
  }

  Future<String?> idm_sdk_serviceID20(String captureBack, int clientTraceId) async {
throw UnimplementedError('platformVersion() has not been implemented.');
  }

  Future<String?> idm_sdk_serviceID10(String captureBack, int clientTraceId) async {
throw UnimplementedError('platformVersion() has not been implemented.');
  } 

   Future<String?> idm_sdk_serviceID50(int uniqueCustomerNumber) async {
throw UnimplementedError('platformVersion() has not been implemented.');
  }

   Future<String?> idm_sdk_serviceID175(int uniqueCustomerNumber) async {
throw UnimplementedError('platformVersion() has not been implemented.');
  }

   Future<String?> idm_sdk_serviceID105(int uniqueCustomerNumber) async {
throw UnimplementedError('platformVersion() has not been implemented.');
  }    

   Future<String?> idm_sdk_serviceID185() async {
throw UnimplementedError('platformVersion() has not been implemented.');
  } 

   Future<String?> idm_sdk_serviceID660() async {
throw UnimplementedError('platformVersion() has not been implemented.');
  } 

  Future<String?> submit_result() async {
throw UnimplementedError('platformVersion() has not been implemented.');
  } 
}
