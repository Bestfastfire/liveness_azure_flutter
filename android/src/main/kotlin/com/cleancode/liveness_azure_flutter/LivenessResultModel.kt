package com.cleancode.liveness_azure_flutter

import android.os.Parcelable
import com.azure.android.ai.vision.faceanalyzer.LivenessFailureReason
import com.azure.android.ai.vision.faceanalyzer.LivenessStatus
import com.azure.android.ai.vision.faceanalyzer.RecognitionStatus
import kotlinx.parcelize.Parcelize

@Parcelize
data class LivenessResultModel(
    val livenessStatus: LivenessStatus,
    val failureReason: LivenessFailureReason,
    val verificationStatus: RecognitionStatus,
    val confidence: Float,
    val resultId: String,
    val digest: String,
    val faceUID: String,
) : Parcelable