import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'liveness_azure_flutter_method_channel.dart';

abstract class LivenessAzureFlutterPlatform extends PlatformInterface {
  /// Constructs a LivenessAzureFlutterPlatform.
  LivenessAzureFlutterPlatform() : super(token: _token);

  static final Object _token = Object();

  static LivenessAzureFlutterPlatform _instance = MethodChannelLivenessAzureFlutter();

  /// The default instance of [LivenessAzureFlutterPlatform] to use.
  ///
  /// Defaults to [MethodChannelLivenessAzureFlutter].
  static LivenessAzureFlutterPlatform get instance => _instance;

  /// Platform-specific implementations should set this with their own
  /// platform-specific class that extends [LivenessAzureFlutterPlatform] when
  /// they register themselves.
  static set instance(LivenessAzureFlutterPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  Future<String?> getPlatformVersion() {
    throw UnimplementedError('platformVersion() has not been implemented.');
  }
}
