import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_plugin_identity_sdk/flutter_plugin_identity_sdk.dart';
import 'package:flutter_plugin_identity_sdk/flutter_plugin_identity_sdk_platform_interface.dart';
import 'package:flutter_plugin_identity_sdk/flutter_plugin_identity_sdk_method_channel.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

class MockFlutterPluginIdentitySdkPlatform
    with MockPlatformInterfaceMixin
    implements FlutterPluginIdentitySdkPlatform {

  @override
  Future<String?> getPlatformVersion() => Future.value('42');
}

void main() {
  final FlutterPluginIdentitySdkPlatform initialPlatform = FlutterPluginIdentitySdkPlatform.instance;

  test('$MethodChannelFlutterPluginIdentitySdk is the default instance', () {
    expect(initialPlatform, isInstanceOf<MethodChannelFlutterPluginIdentitySdk>());
  });

  test('getPlatformVersion', () async {
    FlutterPluginIdentitySdk flutterPluginIdentitySdkPlugin = FlutterPluginIdentitySdk();
    MockFlutterPluginIdentitySdkPlatform fakePlatform = MockFlutterPluginIdentitySdkPlatform();
    FlutterPluginIdentitySdkPlatform.instance = fakePlatform;

    expect(await flutterPluginIdentitySdkPlugin.getPlatformVersion(), '42');
  });
}
