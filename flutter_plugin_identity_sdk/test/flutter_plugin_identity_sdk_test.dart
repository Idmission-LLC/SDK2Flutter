import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_plugin_identity_sdk/flutter_plugin_identity_sdk.dart';
import 'package:flutter_plugin_identity_sdk/flutter_plugin_identity_sdk_platform_interface.dart';
import 'package:flutter_plugin_identity_sdk/flutter_plugin_identity_sdk_method_channel.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

/// Records what the public API passes to the platform. Extends the interface
/// so members a test does not use keep their default behaviour.
class FakePlatform extends FlutterPluginIdentitySdkPlatform with MockPlatformInterfaceMixin {
  Map<String, Object?>? initArgs;

  @override
  Future<String?> idm_sdk_init(String apiBaseUrl, String accessToken,
      {String language = 'en',
      bool enableGPS = true,
      bool geolocationRequired = false,
      bool isUpdateModelsData = true,
      bool enableScreenRecording = false,
      bool enableDebugMode = false}) async {
    initArgs = {
      'apiBaseUrl': apiBaseUrl,
      'accessToken': accessToken,
      'language': language,
      'enableGPS': enableGPS,
      'geolocationRequired': geolocationRequired,
      'isUpdateModelsData': isUpdateModelsData,
      'enableScreenRecording': enableScreenRecording,
      'enableDebugMode': enableDebugMode,
    };
    return 'SDK Successfully Initialized';
  }

  @override
  Future<Map<String, dynamic>> getSDKInfo() async => {'version': 'v', 'models': []};
}

void main() {
  final initialPlatform = FlutterPluginIdentitySdkPlatform.instance;

  test('$MethodChannelFlutterPluginIdentitySdk is the default instance', () {
    expect(initialPlatform, isInstanceOf<MethodChannelFlutterPluginIdentitySdk>());
  });

  group('public API', () {
    late FakePlatform fake;

    setUp(() {
      fake = FakePlatform();
      FlutterPluginIdentitySdkPlatform.instance = fake;
    });

    tearDown(() => FlutterPluginIdentitySdkPlatform.instance = initialPlatform);

    test('idm_sdk_init applies the documented option defaults', () async {
      final result = await FlutterPluginIdentitySdk.idm_sdk_init('https://api.idmission.com/', 'TOKEN');

      expect(result, 'SDK Successfully Initialized');
      expect(fake.initArgs, {
        'apiBaseUrl': 'https://api.idmission.com/',
        'accessToken': 'TOKEN',
        'language': 'en',
        'enableGPS': true,
        'geolocationRequired': false,
        'isUpdateModelsData': true,
        'enableScreenRecording': false,
        'enableDebugMode': false,
      });
    });

    test('idm_sdk_init passes the options through', () async {
      await FlutterPluginIdentitySdk.idm_sdk_init('u', 't',
          language: 'ar', enableGPS: false, geolocationRequired: true, isUpdateModelsData: false, enableScreenRecording: true, enableDebugMode: true);

      expect(fake.initArgs!['language'], 'ar');
      expect(fake.initArgs!['enableGPS'], false);
      expect(fake.initArgs!['geolocationRequired'], true);
      expect(fake.initArgs!['isUpdateModelsData'], false);
      expect(fake.initArgs!['enableScreenRecording'], true);
      expect(fake.initArgs!['enableDebugMode'], true);
    });

    test('getSDKInfo is forwarded to the platform', () async {
      expect((await FlutterPluginIdentitySdk.getSDKInfo())['version'], 'v');
    });
  });
}
