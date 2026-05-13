import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'okhi_flutter_platform_interface.dart';

/// An implementation of [OkhiFlutterPlatform] that uses method channels.
class MethodChannelOkhiFlutter extends OkhiFlutterPlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel('okhi_flutter');

  @override
  Future<String?> getPlatformVersion() async {
    final version =
        await methodChannel.invokeMethod<String>('getPlatformVersion');
    return version;
  }
}
