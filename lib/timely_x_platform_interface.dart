import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'timely_x_method_channel.dart';

abstract class TimelyXFlutterPlatform extends PlatformInterface {
  /// Constructs a TimelyXFlutterPlatform.
  TimelyXFlutterPlatform() : super(token: _token);

  static final Object _token = Object();

  static TimelyXFlutterPlatform _instance = MethodChannelTimelyXFlutter();

  /// The default instance of [TimelyXFlutterPlatform] to use.
  ///
  /// Defaults to [MethodChannelTimelyXFlutter].
  static TimelyXFlutterPlatform get instance => _instance;

  /// Platform-specific implementations should set this with their own
  /// platform-specific class that extends [TimelyXFlutterPlatform] when
  /// they register themselves.
  static set instance(TimelyXFlutterPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }
}
