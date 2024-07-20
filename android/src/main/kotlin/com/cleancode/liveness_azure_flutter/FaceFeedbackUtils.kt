package com.cleancode.liveness_azure_flutter

import com.azure.android.ai.vision.faceanalyzer.FeedbackForFace

class FaceFeedbackUtils private constructor(private var data: Map<String, Any>){
    companion object {
        val shared: FaceFeedbackUtils by lazy { FaceFeedbackUtils(emptyMap()) }

        fun initialize(data: Map<String, Any>?) {
            if(data != null){
                shared.updateFeedbackMessages(data)

            }
        }

        fun faceFeedbackToString(feedback: FeedbackForFace): String {
            return when (feedback) {
                FeedbackForFace.FACE_NOT_CENTERED -> shared.faceNotCentered
                FeedbackForFace.LOOK_AT_CAMERA -> shared.lookAtCamera
                FeedbackForFace.MOVE_BACK -> shared.moveBack
                FeedbackForFace.MOVE_CLOSER -> shared.moveCloser
                FeedbackForFace.CONTINUE_TO_MOVE_CLOSER -> shared.continueToMoveCloser
                FeedbackForFace.REDUCE_MOVEMENT -> shared.tooMuchMovement
                FeedbackForFace.ATTENTION_NOT_NEEDED -> shared.attentionNotNeeded
                else -> shared.none
            }
        }
    }

    val faceNotCentered: String
        get() = data["feedback_face_not_centered"] as? String ?: "Centralize seu rosto no círculo."

    val lookAtCamera: String
        get() = data["feedback_look_at_camera"] as? String ?: "Olhe para a câmera."

    val feedbackMoveBack: String
        get() = data["feedback_move_back"] as? String ?: "Muito perto! Afaste-se mais."

    val moveBack: String
        get() = data["feedback_move_back"] as? String ?: "Muito perto! Afaste-se mais."

    val moveCloser: String
        get() = data["feedback_move_closer"] as? String ?: "Muito longe! Chegue mais perto."

    val continueToMoveCloser: String
        get() = data["feedback_continue_to_move_closer"] as? String ?: "Continue se aproximando."

    val tooMuchMovement: String
        get() = data["feedback_reduce_movement"] as? String ?: "Muito movimento."

    val attentionNotNeeded: String
        get() = data["feedback_attention_not_needed"] as? String ?: "Pronto, finalizando..."

    val none: String
        get() = data["feedback_none"] as? String ?: "Fique Parado"

    private fun updateFeedbackMessages(data: Map<String, Any>) {
        this.data = data
    }
}