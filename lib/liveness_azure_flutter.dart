
import 'liveness_azure_flutter_platform_interface.dart';

class LivenessAzureFlutter {
  Future<String?> getPlatformVersion() {
    return LivenessAzureFlutterPlatform.instance.getPlatformVersion();
  }
}
