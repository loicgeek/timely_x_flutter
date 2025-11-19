import 'package:flutter_test/flutter_test.dart';
import 'package:calendar2/calendar2.dart';
import 'package:calendar2/calendar2_platform_interface.dart';
import 'package:calendar2/calendar2_method_channel.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

class MockCalendar2Platform
    with MockPlatformInterfaceMixin
    implements Calendar2Platform {

  @override
  Future<String?> getPlatformVersion() => Future.value('42');
}

void main() {
  final Calendar2Platform initialPlatform = Calendar2Platform.instance;

  test('$MethodChannelCalendar2 is the default instance', () {
    expect(initialPlatform, isInstanceOf<MethodChannelCalendar2>());
  });

  test('getPlatformVersion', () async {
    Calendar2 calendar2Plugin = Calendar2();
    MockCalendar2Platform fakePlatform = MockCalendar2Platform();
    Calendar2Platform.instance = fakePlatform;

    expect(await calendar2Plugin.getPlatformVersion(), '42');
  });
}
