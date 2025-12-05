// In order to *not* need this ignore, consider extracting the "web" version
// of your plugin as a separate package, instead of inlining it in the same
// package as the core of your plugin.
// ignore: avoid_web_libraries_in_flutter

import 'package:flutter_web_plugins/flutter_web_plugins.dart';
import 'package:web/web.dart' as web;

import 'timely_x_platform_interface.dart';

/// A web implementation of the TimelyXPlatform of the TimelyX plugin.
class TimelyXWeb extends TimelyXPlatform {
  /// Constructs a TimelyXWeb
  TimelyXWeb();

  static void registerWith(Registrar registrar) {
    TimelyXPlatform.instance = TimelyXWeb();
  }

  /// Returns a [String] containing the version of the platform.
  @override
  Future<String?> getPlatformVersion() async {
    final version = web.window.navigator.userAgent;
    return version;
  }
}
