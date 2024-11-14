
import 'timely_x_flutter_platform_interface.dart';

class TimelyXFlutter {
  Future<String?> getPlatformVersion() {
    return TimelyXFlutterPlatform.instance.getPlatformVersion();
  }
}
