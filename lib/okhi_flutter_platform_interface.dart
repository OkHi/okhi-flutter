import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'okhi_flutter_method_channel.dart';

abstract class OkhiFlutterPlatform extends PlatformInterface {
  OkhiFlutterPlatform() : super(token: _token);

  static final Object _token = Object();

  static OkhiFlutterPlatform _instance = MethodChannelOkhiFlutter();

  static OkhiFlutterPlatform get instance => _instance;

  static set instance(OkhiFlutterPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  Future<String?> getPlatformVersion() {
    throw UnimplementedError('platformVersion() has not been implemented.');
  }
}
