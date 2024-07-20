import Foundation
import SwiftUI
import AVFoundation
import AzureAIVisionFace

struct LivenessView: View {
    @EnvironmentObject var livenessModel: LivenessModel
    @State private var actor: LivenessActor? = nil
    @State private var result: LivenessResultModel? = nil
    @State private var feedbackMessage: String = FaceFeedbackUtils.shared.none
    @State private var backgroundColor: Color? = Color.white
    @State private var isCameraPreviewVisible: Bool = true
    let sessionAuthorizationToken: String
    let completionHandler: (LivenessResultModel?) -> Void
    let detailsHandler: (FaceAnalyzedDetails?) -> Void
    let onDismiss: () -> Void

    init(sessionAuthorizationToken: String,
         completionHandler: @escaping (LivenessResultModel?) -> Void = { _ in},
         detailsHandler: @escaping (FaceAnalyzedDetails?) -> Void = { _ in },
         onDismiss: @escaping () -> Void)
    {
        self.sessionAuthorizationToken = sessionAuthorizationToken
        self.completionHandler = completionHandler
        self.detailsHandler = detailsHandler
        self.onDismiss = onDismiss
    }

    var body: some View {
        ZStack(alignment: .center) {
            CameraView(
                backgroundColor: $backgroundColor,
                feedbackMessage: $feedbackMessage,
                isCameraPreviewVisible: $isCameraPreviewVisible) { visionSource in
                    Task {
                        if self.livenessModel.analyzer == nil {
                            do {
                                guard let analyzer = try await LivenessActor.createFaceAnalyzer(
                                    source: visionSource,
                                    sessionAuthorizationToken: self.sessionAuthorizationToken) else {
                                    print("Error creating FaceAnalyzer")
                                    self.feedbackMessage = ""
                                    self.actionDidComplete()
                                    return
                                }
                                
                                self.livenessModel.analyzer = analyzer
                                
                            } catch {
                                print("Error configuring service")
                                self.feedbackMessage = ""
                                self.actionDidComplete()
                                return
                            }
                        }
                        self.actor = self.actor ?? LivenessActor.init(
                            faceAnalyzer: self.livenessModel.analyzer!,
                            sessionAuthorizationToken: self.sessionAuthorizationToken,
                            userFeedbackHandler: { feedback in
                                self.feedbackMessage = feedback
                            },
                            resultHandler: { result in
                                self.result = result
                                self.actionDidComplete()
                            },
                            screenBackgroundColorHandler: { color in
                                self.backgroundColor = color
                            },
                            detailsHandler: { faceAnalyzedDetails in
                                self.detailsHandler(faceAnalyzedDetails)
                            },
                            stopCameraHandler: {
                                self.isCameraPreviewVisible = false
                            })
                        self.isCameraPreviewVisible = true
                        await self.actor?.start()
                    }
                }
        }
        .onDisappear {
            onDismiss()
        }
    }

    func actionDidComplete() {
        self.actor?.stopAnalyzer()
        self.completionHandler(result)
    }
}

