import Foundation
import SwiftUI
import AVFoundation
import AzureAIVisionFace

class LivenessActor{
    private var resultId: String = ""
    private var resultDigest: String = ""
    private let faceAnalyzer: FaceAnalyzer
    private let userFeedbackHandler: (String) -> Void
    private let screenBackgroundColorHandler: (Color) -> Void
    private let resultHandler: (LivenessResultModel?) -> Void
    private let detailsHandler: (FaceAnalyzedDetails?) -> Void
    private let stopCameraHandler: () -> Void
    private let sessionAuthorizationToken: String

    init(faceAnalyzer: FaceAnalyzer,
         sessionAuthorizationToken: String,
         userFeedbackHandler: @escaping (String) -> Void,
         resultHandler: @escaping (LivenessResultModel?) -> Void,
         screenBackgroundColorHandler: @escaping (Color) -> Void,
         detailsHandler: @escaping (FaceAnalyzedDetails?) -> Void,
         stopCameraHandler: @escaping () -> Void) {
        self.sessionAuthorizationToken = sessionAuthorizationToken
        self.faceAnalyzer = faceAnalyzer
        self.resultHandler = resultHandler
        self.userFeedbackHandler = userFeedbackHandler
        self.screenBackgroundColorHandler = screenBackgroundColorHandler
        self.detailsHandler = detailsHandler
        self.stopCameraHandler = stopCameraHandler
    }
    
    func stopAnalyzer() {
        try! self.faceAnalyzer.stopAnalyzeOnce()
    }
    
    static func createFaceAnalyzer(source: VisionSource,
                                   sessionAuthorizationToken: String) async throws -> FaceAnalyzer? {
        guard let createOptions = try? FaceAnalyzerCreateOptions() else {
            return nil
        }

        let serviceOptions = try VisionServiceOptions()
        serviceOptions.authorizationToken = sessionAuthorizationToken

        createOptions.faceAnalyzerMode = FaceAnalyzerMode.trackFacesAcrossImageStream
        return try await FaceAnalyzer.create(serviceOptions: serviceOptions, input: source, createOptions: createOptions)
    }

    func start() async {
        self.faceAnalyzer.addAnalyzedEventHandler {[] (analyzer: FaceAnalyzer, result: FaceAnalyzedResult) in
            guard result.faces.count != 0  else {
                self.resultHandler(nil)
                return
            }
            
            self.userFeedbackHandler("")

            let face = result.faces[result.faces.startIndex]
            let faceAnalyzedDetails = result.faceAnalyzedDetails;
            
            let livenessStatus = face.livenessResult?.status.rawValue
            let failureReason = face.livenessResult?.failureReason.rawValue
            let verificationStatus = face.recognitionResult?.recognitionStatus.rawValue
            let confidence = face.recognitionResult?.confidence
            let resultId = face.livenessResult?.resultId.uuidString
            let digest = faceAnalyzedDetails?.digest
            let faceUid = face.uuid.uuidString.lowercased()
            
            self.resultHandler(LivenessResultModel(livenessStatus: String(describing: verificationStatus),
                                                   failureReason: String(describing: livenessStatus),
                                                   verificationStatus: String(describing: failureReason),
                                                   confidence: confidence,
                                                   resultId: resultId,
                                                   digest: digest,
                                                   faceUID: faceUid))
            
            self.detailsHandler(faceAnalyzedDetails)
        }

        self.faceAnalyzer.addAnalyzingEventHandler { (analyzer: FaceAnalyzer, result: FaceAnalyzingResult) in
            guard  result.faces.count != 0  else {
                self.resultHandler(nil)
                return
            }
            
            let face = result.faces[result.faces.startIndex]

            if let action = face.actionRequired?.action {
                switch(action){
                case .brightenDisplay:
                    self.screenBackgroundColorHandler(Color.white)
                    break
                    
                case .darkenDisplay: 
                    self.screenBackgroundColorHandler(Color.black)
                    break
                    
                case .stopCamera: 
                    self.stopCameraHandler()
                    break
                    
                default: 
                    break
                }

                face.actionRequired?.complete()
            }

            self.userFeedbackHandler(FaceFeedbackUtils.faceFeedbackToString(
                feedback: face.feedbackForFace))
        }

        self.faceAnalyzer.addSessionStartedEventHandler { analyzer, evt in
            print("session started event callback")
        }

        self.faceAnalyzer.addSessionStoppedEventHandler {[weak self] FaceAnalyzer, session, evt in
            print("session stopped event callback")
            self!.userFeedbackHandler(FaceFeedbackUtils.shared.attentionNotNeeded)
        }

        let methodOptions: FaceAnalysisOptions
        do {
            methodOptions = try FaceAnalysisOptions()
            methodOptions.faceSelectionMode = FaceSelectionMode.largest
            
        } catch {
            self.resultHandler(nil)
            return
            
        }

        self.faceAnalyzer.analyzeOnce(using: methodOptions, completionHandler: { (result, error) in
            print("analyzeOnce completion handler")
        })
    }
}
