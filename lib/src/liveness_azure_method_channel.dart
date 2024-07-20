import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'interface/liveness_azure_platform_interface.dart';
import 'utils/liveness_theme.dart';

/// An implementation of [LivenessAzureFlutterPlatform] that uses method channels.
class MethodChannelLivenessAzureFlutter extends LivenessAzureFlutterPlatform {
  @visibleForTesting
  final methodChannel = const MethodChannel('liveness_azure_flutter');

  @override
  Future<String?> initLiveness(String authTokenSession,
      {LivenessTheme theme = const LivenessTheme(), String? imagePath}) async {
    final args = {'authTokenSession': authTokenSession, ...theme.asMap};

    return await methodChannel.invokeMethod<String>('initLiveness', args);
  }

  @override
  Future<String?> getDeviceUID() async {
    return await methodChannel.invokeMethod<String>('getDeviceUID');
  }
}
