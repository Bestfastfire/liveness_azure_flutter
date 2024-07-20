# Liveness Azure Flutter
Check it out at [Pub.Dev](https://pub.dev/packages/liveness_azure_flutter)

A Flutter plugin for iOS and Android for liveness with Azure AI API

|             | Android | iOS     | Linux | macOS | Web | Windows |
|-------------|---------|---------|-------|-------|-----|---------|
| **Support** | SDK 24+ | iOS 14+ | No    | No    | No  | No      |

## Setup

## Android
Follow this steps to generate your `accessToken`: [GET_FACE_ARTIFACTS_ACCESS](https://github.com/Azure-Samples/azure-ai-vision-sdk/blob/main/GET_FACE_ARTIFACTS_ACCESS.md)

Then in your `gradle.properties` add this lines (For more info: [Android Azure AI](https://github.com/Azure-Samples/azure-ai-vision-sdk/blob/main/samples/kotlin/face/FaceAnalyzerSample/README.md)):

```
maveUser=any_user
mavenPassword=accessToken
```

## iOS
Follow this steps to generate your `accessToken`: [GET_FACE_ARTIFACTS_ACCESS](https://github.com/Azure-Samples/azure-ai-vision-sdk/blob/main/GET_FACE_ARTIFACTS_ACCESS.md)

Then in your `Podfile` add this lines:

```
...
source 'https://github.com/CocoaPods/Specs.git'
source 'https://msface.visualstudio.com/SDK/_git/AzureAIVisionCore.podspec'
source 'https://msface.visualstudio.com/SDK/_git/AzureAIVisionFace.podspec'
...
```

Add in your `Info.plist` this keys:
```
<key>NSCameraUsageDescription</key>
<string>Describe...</string>
<key>NSMicrophoneUsageDescription</key>
<string>Describe...</string>
```

Probably, with xcode, you will see a pop-up window asking for username and password. Make a random username and use the `accessToken` from previous step to be the password.
For more info: [iOS Azure AI](https://github.com/Azure-Samples/azure-ai-vision-sdk/blob/main/samples/swift/face/FaceAnalyzerSample/README.md)

## Getting Started
After setup you can do:

```
// You will need use another plugin, in this case is [permission_handler](https://pub.dev/packages/permission_handler), to get camera permission.
Future<PermissionStatus> requestCameraPermission() async{
    return Permission.camera.request();
}

Future initLiveness() async{
    if(await requestCameraPermission() == PermissionStatus.granted){
        // It is not recommended to use this method in a real project, the session token must be obtained from the client backend.
        final session = await LivenessAzureFlutter.createSession(
            faceApiEndpoint: 'yourFaceApiEndpoint',
            apiKey: 'apikey1234');
            
        if(session != null){
            try{
                // Now it will open a new screen to liveness
                final liveness = await LivenessAzureFlutter.initLiveness(
                    authTokenSession: session.authSession,
                    
                    // You can customize texts feedback or leave default (exists too LivenessTheme.pt() to portuguese)
                    theme: const LivenessTheme(
                          feedbackNone: 'Hold Still.',
                          feedbackLookAtCamera: 'Look at camera.',
                          feedbackFaceNotCentered: 'Center your face in the circle.',
                          feedbackMoveCloser: 'Too far away! Move in closer.',
                          feedbackContinueToMoveCloser: 'Continue to move closer.',
                          feedbackMoveBack: 'Too close! Move farther away.',
                          feedbackReduceMovement: 'Too much movement.',
                          feedbackSmile: 'Smile for the camera!',
                          feedbackAttentionNotNeeded: 'Done, finishing up...')););
                
                print('liveness result: ${liveness?.resultId}');
            
            }catch(msg, stacktrace){
                // handler error
            
            }
        }
    }
}
```