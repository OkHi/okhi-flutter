import 'package:flutter_test/flutter_test.dart';
import 'package:okhi_flutter/okhi_flutter.dart';
import 'package:okhi_flutter/okhi_flutter_platform_interface.dart';
import 'package:okhi_flutter/okhi_flutter_method_channel.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

class MockOkhiFlutterPlatform
    with MockPlatformInterfaceMixin
    implements OkhiFlutterPlatform {
  @override
  Future<String?> getPlatformVersion() => Future.value('42');
}

void main() {
  final OkhiFlutterPlatform initialPlatform = OkhiFlutterPlatform.instance;

  test('$MethodChannelOkhiFlutter is the default instance', () {
    expect(initialPlatform, isInstanceOf<MethodChannelOkhiFlutter>());
  });

  test('getPlatformVersion', () async {
    MockOkhiFlutterPlatform fakePlatform = MockOkhiFlutterPlatform();
    OkhiFlutterPlatform.instance = fakePlatform;

    expect(await OkHi.platformVersion, '42');
  });
}
