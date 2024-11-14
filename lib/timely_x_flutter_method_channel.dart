import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'timely_x_flutter_platform_interface.dart';

/// An implementation of [TimelyXFlutterPlatform] that uses method channels.
class MethodChannelTimelyXFlutter extends TimelyXFlutterPlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel('timely_x_flutter');

  @override
  Future<String?> getPlatformVersion() async {
    final version = await methodChannel.invokeMethod<String>('getPlatformVersion');
    return version;
  }
}
