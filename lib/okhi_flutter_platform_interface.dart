import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'okhi_flutter_method_channel.dart';

abstract class OkhiFlutterPlatform extends PlatformInterface {
  /// Constructs a OkhiFlutterPlatform.
  OkhiFlutterPlatform() : super(token: _token);

  static final Object _token = Object();

  static OkhiFlutterPlatform _instance = MethodChannelOkhiFlutter();

  /// The default instance of [OkhiFlutterPlatform] to use.
  ///
  /// Defaults to [MethodChannelOkhiFlutter].
  static OkhiFlutterPlatform get instance => _instance;

  /// Platform-specific implementations should set this with their own
  /// platform-specific class that extends [OkhiFlutterPlatform] when
  /// they register themselves.
  static set instance(OkhiFlutterPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  Future<String?> getPlatformVersion() {
    throw UnimplementedError('platformVersion() has not been implemented.');
  }
}
