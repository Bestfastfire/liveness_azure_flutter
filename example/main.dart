import 'package:liveness_azure_flutter/liveness_azure_flutter.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter/material.dart';
import 'dart:async';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  Future<PermissionStatus> requestCameraPermission() async{
    return Permission.camera.request();
  }

  Future initLiveness() async{
    if(await requestCameraPermission() == PermissionStatus.granted){
      final session = await LivenessAzureFlutter.createSession(
          faceApiEndpoint: 'faceApiEndpoint',
          apiKey: 'apikey1234');

      if(session != null){
        try{
          final liveness = await LivenessAzureFlutter.initLiveness(
              authTokenSession: session.authSession,
              theme: const LivenessTheme(
                  feedbackNone: 'Hold Still.',
                  feedbackLookAtCamera: 'Look at camera.',
                  feedbackFaceNotCentered: 'Center your face in the circle.',
                  feedbackMoveCloser: 'Too far away! Move in closer.',
                  feedbackContinueToMoveCloser: 'Continue to move closer.',
                  feedbackMoveBack: 'Too close! Move farther away.',
                  feedbackReduceMovement: 'Too much movement.',
                  feedbackSmile: 'Smile for the camera!',
                  feedbackAttentionNotNeeded: 'Done, finishing up...'));

          print('liveness result: ${liveness?.resultId}');

        }catch(msg, stacktrace){
          // error

        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Plugin example app')),
        body: Center(child: FutureBuilder(
            future: requestCameraPermission(),
            builder: (c, snapshot){
              if(snapshot.connectionState != ConnectionState.done){
                return const CircularProgressIndicator();

              }

              return TextButton(
                  onPressed: initLiveness,
                  child: const Text("Init Liveness"));
            }))));
  }
}
