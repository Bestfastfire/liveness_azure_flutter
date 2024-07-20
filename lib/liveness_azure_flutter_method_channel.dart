import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'liveness_azure_flutter_platform_interface.dart';

/// An implementation of [LivenessAzureFlutterPlatform] that uses method channels.
class MethodChannelLivenessAzureFlutter extends LivenessAzureFlutterPlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel('liveness_azure_flutter');

  @override
  Future<String?> getPlatformVersion() async {
    final version = await methodChannel.invokeMethod<String>('getPlatformVersion');
    return version;
  }
}
