import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'timely_x_method_channel.dart';

abstract class TimelyXPlatform extends PlatformInterface {
  /// Constructs a TimelyXPlatform.
  TimelyXPlatform() : super(token: _token);

  static final Object _token = Object();

  static TimelyXPlatform _instance = MethodChannelTimelyX();

  /// The default instance of [TimelyXPlatform] to use.
  ///
  /// Defaults to [MethodChannelTimelyX].
  static TimelyXPlatform get instance => _instance;

  /// Platform-specific implementations should set this with their own
  /// platform-specific class that extends [TimelyXPlatform] when
  /// they register themselves.
  static set instance(TimelyXPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  Future<String?> getPlatformVersion() {
    throw UnimplementedError('platformVersion() has not been implemented.');
  }
}
