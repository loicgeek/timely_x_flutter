import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'calendar2_method_channel.dart';

abstract class Calendar2Platform extends PlatformInterface {
  /// Constructs a Calendar2Platform.
  Calendar2Platform() : super(token: _token);

  static final Object _token = Object();

  static Calendar2Platform _instance = MethodChannelCalendar2();

  /// The default instance of [Calendar2Platform] to use.
  ///
  /// Defaults to [MethodChannelCalendar2].
  static Calendar2Platform get instance => _instance;

  /// Platform-specific implementations should set this with their own
  /// platform-specific class that extends [Calendar2Platform] when
  /// they register themselves.
  static set instance(Calendar2Platform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  Future<String?> getPlatformVersion() {
    throw UnimplementedError('platformVersion() has not been implemented.');
  }
}
