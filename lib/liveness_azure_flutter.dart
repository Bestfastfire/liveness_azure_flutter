import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';

import 'src/interface/liveness_azure_platform_interface.dart';
import 'src/utils/liveness_session.dart';
import 'src/utils/liveness_result.dart';
import 'src/utils/liveness_theme.dart';

class LivenessAzureFlutter {
  /// It is not recommended to use this method in a real project, the session token must be obtained from the client backend
  static Future<LivenessSession?> createSession({
    /// Your faceApiEndpoint
    required String faceApiEndpoint,
    /// Your key
    required String apiKey,
    /// Unique deviceUID
    String? deviceCorrelationId,
    /// ImagePath of image to verify
    String? imagePath,
    /// Enable/Disable save image while liveness (only apiVersion >= v1.2-preview.1)
    bool enableSessionImage = false,
    /// Api version of azure face API
    String apiVersion = 'v1.2-preview.1'
  }) async{
    final verifyImage = imagePath != null;
    final deviceUID = deviceCorrelationId ?? await LivenessAzureFlutterPlatform.instance.getDeviceUID();
    if(deviceUID == null){
      throw Exception('deviceCorrelationId cannot be null');

    }

    final detectType = verifyImage ? 'detectLivenessWithVerify' : 'detectLiveness';
    final createSessionUri = '$faceApiEndpoint/face/$apiVersion/$detectType/singleModal/sessions';

    final parameters = {
      'enableSessionImage': enableSessionImage,
      'livenessOperationMode': 'Passive',
      'deviceCorrelationId': deviceUID,
      'sendResultsToClient': true
    };

    final dio = Dio();

    FormData? formData;
    if (imagePath != null){
      final imageFile = File(imagePath);
      formData = FormData.fromMap({
        'Parameters': jsonEncode(parameters),
        'VerifyImage': await MultipartFile.fromFile(imageFile.path)
      });

    } else {
      dio.options.headers['Content-Type'] = 'application/json';

    }

    dio.options.headers['Ocp-Apim-Subscription-Key'] = apiKey;

    final response = !verifyImage
        ? await dio.post(createSessionUri, data: jsonEncode(parameters))
        : await dio.post(createSessionUri, data: formData);

    if (response.statusCode != null && response.statusCode! >= 200 && response.statusCode! < 300) {
      final data = response.data;
      if(data['authToken'] != null){
        return LivenessSession(
            authSession: data['authToken'],
            sessionId: data['sessionId']);

      }
    }

    return null;
  }

  static Future<LivenessResult?> initLiveness({
    /// AuthToken returned by [createSession] or your backend
    required String authTokenSession,
    /// Custom texts during liveness
    LivenessTheme theme = const LivenessTheme()
  }) async{
    final result = await LivenessAzureFlutterPlatform.instance.initLiveness(
        authTokenSession, theme: theme);

    if(result != null){
      return LivenessResult.fromJson(jsonDecode(result));

    }

    return null;
  }
}
