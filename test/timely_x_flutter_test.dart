import 'package:flutter_test/flutter_test.dart';
import 'package:timely_x/timely_x.dart';
import 'package:timely_x/timely_x_platform_interface.dart';
import 'package:timely_x/timely_x_method_channel.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

class MockTimelyXFlutterPlatform
    with MockPlatformInterfaceMixin
    implements TimelyXFlutterPlatform {
  @override
  Future<String?> getPlatformVersion() => Future.value('42');
}

void main() {
  final TimelyXFlutterPlatform initialPlatform =
      TimelyXFlutterPlatform.instance;

  test('$MethodChannelTimelyXFlutter is the default instance', () {
    expect(initialPlatform, isInstanceOf<MethodChannelTimelyXFlutter>());
  });

  test('getPlatformVersion', () async {
    TimelyXFlutter TimelyXPlugin = TimelyXFlutter();
    MockTimelyXFlutterPlatform fakePlatform = MockTimelyXFlutterPlatform();
    TimelyXFlutterPlatform.instance = fakePlatform;

    expect(await TimelyXPlugin.getPlatformVersion(), '42');
  });
}
