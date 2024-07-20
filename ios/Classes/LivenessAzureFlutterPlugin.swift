import Flutter
import SwiftUI

public class LivenessAzureFlutterPlugin: NSObject, FlutterPlugin {
  public static func register(with registrar: FlutterPluginRegistrar) {
    let channel = FlutterMethodChannel(name: "liveness_azure_flutter", binaryMessenger: registrar.messenger())
    let instance = LivenessAzureFlutterPlugin()
    registrar.addMethodCallDelegate(instance, channel: channel)
  }

public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        switch call.method {
        case "initLiveness":
            return presentLivenessView(call: call, result: result)

        case "getDeviceUID":
            return result(getUniqueUID())

        default:
            result(nil)
        }
    }

    private func getUniqueUID() -> String{
        return UIDevice.current.identifierForVendor?.uuidString ?? UUID().uuidString
    }

    private func presentLivenessView(call: FlutterMethodCall, result: @escaping FlutterResult) {
        if let args = call.arguments as? [String: Any],
            let authToken = args["authTokenSession"] as? String{
            FaceFeedbackUtils.initialize(data: args)

            if let rootViewController = UIApplication.shared.delegate?.window??.rootViewController {
                let livenessModel = LivenessModel()
                var skipDismiss = false

                let livenessView = LivenessView(
                    sessionAuthorizationToken: authToken,
                    completionHandler: { resultModel in
                        skipDismiss = true

                        DispatchQueue.main.async {
                            rootViewController.dismiss(animated: true, completion: nil)

                            if let jsonData = try? JSONEncoder().encode(resultModel),
                               let jsonString = String(data: jsonData, encoding: .utf8) {
                                result(jsonString)

                            }else{
                                result(nil)

                            }
                        }
                    },
                    onDismiss: {
                        if(!skipDismiss){
                            result(nil)

                        }
                    })
                    .environmentObject(livenessModel)

                let hostingController = UIHostingController(rootView: livenessView)
                rootViewController.present(hostingController, animated: true, completion: nil)

            } else {
                result(FlutterError(code: "UNAVAILABLE", message: "Root view controller not available", details: nil))
                return
            }
        }else{
            return result(FlutterError(code: "INVALID_ARGUMENT", message: "Invalid arguments", details: nil))

        }
    }
}
