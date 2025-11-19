// In order to *not* need this ignore, consider extracting the "web" version
// of your plugin as a separate package, instead of inlining it in the same
// package as the core of your plugin.
// ignore: avoid_web_libraries_in_flutter

import 'package:flutter_web_plugins/flutter_web_plugins.dart';
import 'package:web/web.dart' as web;

import 'calendar2_platform_interface.dart';

/// A web implementation of the Calendar2Platform of the Calendar2 plugin.
class Calendar2Web extends Calendar2Platform {
  /// Constructs a Calendar2Web
  Calendar2Web();

  static void registerWith(Registrar registrar) {
    Calendar2Platform.instance = Calendar2Web();
  }

  /// Returns a [String] containing the version of the platform.
  @override
  Future<String?> getPlatformVersion() async {
    final version = web.window.navigator.userAgent;
    return version;
  }
}
