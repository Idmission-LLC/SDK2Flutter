import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_plugin_identity_sdk/flutter_plugin_identity_sdk_method_channel.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  final platform = MethodChannelFlutterPluginIdentitySdk();
  const channel = MethodChannel('flutter_plugin_identity_sdk');
  final calls = <MethodCall>[];
  Object? reply;

  setUp(() {
    calls.clear();
    reply = null;
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (MethodCall call) async {
      calls.add(call);
      return reply;
    });
  });

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, null);
  });

  group('idm_sdk_init', () {
    test('sends the required arguments and the default options', () async {
      reply = 'SDK successfully initialized';
      final result = await platform.idm_sdk_init('https://api.idmission.com/', 'n', 'TOKEN');

      expect(result, 'SDK successfully initialized');
      expect(calls.single.method, 'idm_sdk_init');
      expect(calls.single.arguments, {
        'apiBaseUrl': 'https://api.idmission.com/',
        'debug': 'n',
        'accessToken': 'TOKEN',
        'language': 'en',
        'enableGPS': true,
        'geolocationRequired': false,
        'isUpdateModelsData': true,
        'enableScreenRecording': false,
      });
    });

    test('sends the options it is given', () async {
      await platform.idm_sdk_init(
        'https://apidemo.idmission.com/', 'y', 'TOKEN',
        language: 'es',
        enableGPS: false,
        geolocationRequired: true,
        isUpdateModelsData: false,
        enableScreenRecording: true,
      );

      final args = calls.single.arguments as Map;
      expect(args['debug'], 'y');
      expect(args['language'], 'es');
      expect(args['enableGPS'], false);
      expect(args['geolocationRequired'], true);
      expect(args['isUpdateModelsData'], false);
      expect(args['enableScreenRecording'], true);
    });
  });

  group('services', () {
    test('ID 20 and ID 10 send captureBack and clientTraceId', () async {
      await platform.idm_sdk_serviceID20('y', 7);
      await platform.idm_sdk_serviceID10('n', 8);

      expect(calls[0].method, 'idm_sdk_serviceID20');
      expect(calls[0].arguments, {'captureBack': 'y', 'clientTraceId': 7});
      expect(calls[1].method, 'idm_sdk_serviceID10');
      expect(calls[1].arguments, {'captureBack': 'n', 'clientTraceId': 8});
    });

    test('ID 50, 175 and 105 send the unique customer number', () async {
      await platform.idm_sdk_serviceID50(11);
      await platform.idm_sdk_serviceID175(12);
      await platform.idm_sdk_serviceID105(13);

      expect(calls.map((c) => c.method),
          ['idm_sdk_serviceID50', 'idm_sdk_serviceID175', 'idm_sdk_serviceID105']);
      expect(calls.map((c) => (c.arguments as Map)['uniqueCustomerNumber']), [11, 12, 13]);
    });

    test('ID 185, ID 660 and submit_result send no arguments', () async {
      reply = 'result';
      expect(await platform.idm_sdk_serviceID185(), 'result');
      expect(await platform.idm_sdk_serviceID660(), 'result');
      expect(await platform.submit_result(), 'result');

      expect(calls.map((c) => c.method),
          ['idm_sdk_serviceID185', 'idm_sdk_serviceID660', 'submit_result']);
      expect(calls.every((c) => c.arguments == null), isTrue);
    });
  });

  group('getSDKInfo', () {
    test('returns the version and models', () async {
      reply = {
        'version': 'IOS_Medium_11.1.19_2_2',
        'models': [
          {'name': 'Liveness', 'value': 'liveness.tflite'},
        ],
      };
      final info = await platform.getSDKInfo();

      expect(info['version'], 'IOS_Medium_11.1.19_2_2');
      expect((info['models'] as List).single['name'], 'Liveness');
    });

    test('returns an empty map when the platform returns nothing', () async {
      expect(await platform.getSDKInfo(), isEmpty);
    });
  });

  test('getPlatformVersion still works', () async {
    reply = '42';
    expect(await platform.getPlatformVersion(), '42');
  });
}
