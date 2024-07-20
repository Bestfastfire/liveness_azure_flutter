import Foundation
import AzureAIVisionFace

class FaceFeedbackUtils {
    static let shared = FaceFeedbackUtils(data: [:])
    
    private var data: [String: Any]
    
    var faceNotCentered: String { data["feedback_face_not_centered"] as? String ?? "Centralize seu rosto no círculo." }
    var lookAtCamera: String { data["feedback_look_at_camera"] as? String ?? "Olhe para a câmera." }
    var feedbackMoveBack: String { data["feedback_move_back"] as? String ?? "Muito perto! Afaste-se mais." }
    var moveBack: String { data["feedback_move_back"] as? String ?? "Muito perto! Afaste-se mais." }
    var moveCloser: String { data["feedback_move_closer"] as? String ?? "Muito longe! Chegue mais perto." }
    var continueToMoveCloser: String { data["feedback_continue_to_move_closer"] as? String ?? "Continue se aproximando." }
    var tooMuchMovement: String { data["feedback_reduce_movement"] as? String ?? "Muito movimento." }
    var attentionNotNeeded: String { data["feedback_attention_not_needed"] as? String ?? "Pronto, finalizando..." }
    var none: String { data["feedback_none"] as? String ?? "Fique Parado" }
    
    private init(data: [String: Any]) {
        self.data = data
    }
    
    static func initialize(data: [String: Any]) {
        shared.updateFeedbackMessages(data: data)
    }
    
    private func updateFeedbackMessages(data: [String: Any]) {
        self.data = data
    }
    
    static func faceFeedbackToString(feedback: FaceAnalyzingFeedbackForFace) -> String {
        switch feedback {
            case .faceNotCentered: return FaceFeedbackUtils.shared.faceNotCentered
            case .lookAtCamera: return FaceFeedbackUtils.shared.lookAtCamera
            case .moveBack: return FaceFeedbackUtils.shared.moveCloser
            case .moveCloser: return FaceFeedbackUtils.shared.moveCloser
            case .continueToMoveCloser: return FaceFeedbackUtils.shared.continueToMoveCloser
            case .tooMuchMovement: return FaceFeedbackUtils.shared.tooMuchMovement
            case .attentionNotNeeded: return FaceFeedbackUtils.shared.attentionNotNeeded
            default: return FaceFeedbackUtils.shared.none
        }
    }
}
