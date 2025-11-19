import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'calendar2_platform_interface.dart';

/// An implementation of [Calendar2Platform] that uses method channels.
class MethodChannelCalendar2 extends Calendar2Platform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel('calendar2');

  @override
  Future<String?> getPlatformVersion() async {
    final version = await methodChannel.invokeMethod<String>('getPlatformVersion');
    return version;
  }
}
