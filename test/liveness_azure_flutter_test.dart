import 'package:flutter_test/flutter_test.dart';
import 'package:liveness_azure_flutter/liveness_azure_flutter.dart';
import 'package:liveness_azure_flutter/liveness_azure_flutter_platform_interface.dart';
import 'package:liveness_azure_flutter/liveness_azure_flutter_method_channel.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

class MockLivenessAzureFlutterPlatform
    with MockPlatformInterfaceMixin
    implements LivenessAzureFlutterPlatform {

  @override
  Future<String?> getPlatformVersion() => Future.value('42');
}

void main() {
  final LivenessAzureFlutterPlatform initialPlatform = LivenessAzureFlutterPlatform.instance;

  test('$MethodChannelLivenessAzureFlutter is the default instance', () {
    expect(initialPlatform, isInstanceOf<MethodChannelLivenessAzureFlutter>());
  });

  test('getPlatformVersion', () async {
    LivenessAzureFlutter livenessAzureFlutterPlugin = LivenessAzureFlutter();
    MockLivenessAzureFlutterPlatform fakePlatform = MockLivenessAzureFlutterPlatform();
    LivenessAzureFlutterPlatform.instance = fakePlatform;

    expect(await livenessAzureFlutterPlugin.getPlatformVersion(), '42');
  });
}
