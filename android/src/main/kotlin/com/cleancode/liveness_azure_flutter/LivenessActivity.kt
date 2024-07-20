package com.cleancode.liveness_azure_flutter

import android.content.Intent
import android.graphics.Color
import android.hardware.camera2.*
import android.os.Bundle
import android.os.Handler
import android.os.Looper
import android.util.Log
import android.view.SurfaceView
import android.view.View
import android.widget.FrameLayout
import android.widget.TextView
import androidx.activity.addCallback
import androidx.appcompat.app.AppCompatActivity
import androidx.constraintlayout.widget.ConstraintLayout
import androidx.lifecycle.LifecycleOwner
import com.azure.ai.vision.common.internal.implementation.EventListener
import com.azure.android.ai.vision.common.VisionServiceOptions
import com.azure.android.ai.vision.common.VisionSource
import com.azure.android.ai.vision.common.VisionSourceOptions
import com.azure.android.ai.vision.common.implementation.VisionSourceHelper
import com.azure.android.ai.vision.faceanalyzer.*
import com.azure.android.core.credential.AccessToken
import com.azure.android.core.credential.TokenCredential
import com.azure.android.core.credential.TokenRequestContext
import com.google.gson.Gson
import org.threeten.bp.OffsetDateTime
import java.nio.ByteBuffer

open class LivenessActivity : AppCompatActivity() {
    class StringTokenCredential(token: String) : TokenCredential {
        override fun getToken(
            request: TokenRequestContext,
            callback: TokenCredential.TokenCredentialCallback
        ) {
            callback.onSuccess(_token)
        }

        private var _token: AccessToken? = null

        init {
            _token = AccessToken(token, OffsetDateTime.MAX)
        }
    }

    private lateinit var mSurfaceView: SurfaceView
    private lateinit var mCameraPreviewLayout: FrameLayout
    private lateinit var mBackgroundLayout: ConstraintLayout
    private lateinit var mInstructionsView: TextView
    private var lastTextUpdateTime = 0L
    private val delayMillis = 200L
    private var mVisionSource: VisionSource? = null
    private var mFaceAnalyzer: FaceAnalyzer? = null
    private var mFaceAnalysisOptions: FaceAnalysisOptions? = null
    private var mServiceOptions: VisionServiceOptions? = null
    private var mSessionToken: String? = null
    private var mBackPressed: Boolean = false
    private var mHandler = Handler(Looper.getMainLooper())
    private var mDoneAnalyzing: Boolean = false
    private var cameraFrame: ByteBuffer? = null


    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.activity_liveness)
        mSurfaceView = AutoFitSurfaceView(this)
        mCameraPreviewLayout = findViewById(R.id.camera_preview)
        mCameraPreviewLayout.removeAllViews()
        mCameraPreviewLayout.addView(mSurfaceView)
        mCameraPreviewLayout.visibility = View.INVISIBLE
        mInstructionsView = findViewById(R.id.instructionString)
        mBackgroundLayout = findViewById(R.id.activity_main_layout)
        mSessionToken = intent.getStringExtra("authTokenSession")

        if (mSessionToken.isNullOrBlank()) {
            return onSubmit(null)

        }

        onBackPressedDispatcher.addCallback(this){
            onBack()
        }
    }

    override fun onResume() {
        super.onResume()
        if (mFaceAnalyzer == null) {
            initializeConfig()
            val visionSourceOptions = VisionSourceOptions(this, this as LifecycleOwner)
            visionSourceOptions.setPreview(mSurfaceView)
            mVisionSource = VisionSource.fromDefaultCamera(visionSourceOptions)
            displayCameraOnLayout()
            createFaceAnalyzer()

        }

        startAnalyzeOnce()
    }

    override fun onDestroy() {
        super.onDestroy()
        mVisionSource?.close()
        mVisionSource = null
        mServiceOptions?.close()
        mServiceOptions = null
        mFaceAnalysisOptions?.close()
        mFaceAnalysisOptions = null
        try {
            mFaceAnalyzer?.close()
            mFaceAnalyzer = null
        } catch (ex: Exception) {
            ex.printStackTrace()
        }
    }

    private fun initializeConfig() {
        mServiceOptions = VisionServiceOptions(StringTokenCredential(mSessionToken.toString()))
    }

    private fun createFaceAnalyzer() {
        FaceAnalyzerCreateOptions().use { createOptions ->
            createOptions.setFaceAnalyzerMode(FaceAnalyzerMode.TRACK_FACES_ACROSS_IMAGE_STREAM)

            mFaceAnalyzer = FaceAnalyzerBuilder()
                .serviceOptions(mServiceOptions)
                .source(mVisionSource)
                .createOptions(createOptions)
                .build().get()
        }

        mFaceAnalyzer?.apply {
            this.analyzed.addEventListener(analyzedListener)
            this.analyzing.addEventListener(analyzingListener)
            this.stopped.addEventListener(stoppedListener)
        }
    }

    @Suppress("MemberVisibilityCanBePrivate")
    protected var analyzingListener =
        EventListener<FaceAnalyzingEventArgs> { _, e ->

            e.result.use { result ->
                if (result.faces.isNotEmpty()) {
                    // Get the first face in result
                    val face = result.faces.iterator().next()

                    // Lighten/darken the screen based on liveness feedback
                    val requiredAction = face.actionRequiredFromApplicationTask?.action
                    when (requiredAction) {
                        ActionRequiredFromApplication.BRIGHTEN_DISPLAY -> {
                            mBackgroundLayout.setBackgroundColor(Color.WHITE)
                            face.actionRequiredFromApplicationTask.setAsCompleted()
                        }
                        ActionRequiredFromApplication.DARKEN_DISPLAY -> {
                            mBackgroundLayout.setBackgroundColor(Color.BLACK)
                            face.actionRequiredFromApplicationTask.setAsCompleted()
                        }
                        ActionRequiredFromApplication.STOP_CAMERA -> {
                            face.actionRequiredFromApplicationTask.setAsCompleted()
                            mCameraPreviewLayout.visibility = View.INVISIBLE

                        }
                        else -> {}
                    }

                    // Display user feedback and warnings on UI
                    if (!mDoneAnalyzing) {
                        var feedbackMessage = mapFeedbackToMessage(FeedbackForFace.NONE)
                        if (face.feedbackForFace != null) {
                            feedbackMessage = mapFeedbackToMessage(face.feedbackForFace)
                        }

                        val currentTime = System.currentTimeMillis()
                        // Check if enough time has passed since the last update
                        if (currentTime - lastTextUpdateTime >= delayMillis) {
                            // Update the text view
                            updateTextView(feedbackMessage)

                            // Update the last update time
                            lastTextUpdateTime = currentTime
                        }
                    }
                }
            }
        }

    @Suppress("MemberVisibilityCanBePrivate")
    protected var analyzedListener =
        EventListener<FaceAnalyzedEventArgs> { _, e ->
            e.result.use { result ->
                if (result.faces.isNotEmpty()) {
                    val face = result.faces.iterator().next()

                    val livenessStatus: LivenessStatus = face.livenessResult?.livenessStatus?: LivenessStatus.FAILED
                    val livenessFailureReason = face.livenessResult?.livenessFailureReason?: LivenessFailureReason.NONE
                    val verifyStatus = face.recognitionResult?.recognitionStatus?:RecognitionStatus.NOT_COMPUTED
                    val verifyConfidence = face.recognitionResult?.confidence?:0.0.toFloat()
                    val digest = result.details?.digest?:""
                    val resultIds = face.livenessResult.resultId.toString()
                    val faceUid = face.faceUuid.toString()

                    val analyzedResult = LivenessResultModel(livenessStatus, livenessFailureReason, verifyStatus, verifyConfidence, resultIds, digest, faceUid)
                    onSubmit(analyzedResult)

                } else {
                    val analyzedResult = LivenessResultModel(LivenessStatus.NOT_COMPUTED, LivenessFailureReason.NONE, RecognitionStatus.NOT_COMPUTED, 0.0.toFloat(), "", "", "")
                    onSubmit(analyzedResult)

                }
            }
        }

    @Suppress("MemberVisibilityCanBePrivate")
    protected var stoppedListener =
        EventListener<FaceAnalysisStoppedEventArgs> { _, e ->
            if (e.reason == FaceAnalysisStoppedReason.ERROR) {
                onSubmit(null)
            }
        }

    private fun startAnalyzeOnce() {
        mCameraPreviewLayout.visibility = View.VISIBLE

        if (mServiceOptions == null ) {
            return onSubmit(null)

        }

        mFaceAnalysisOptions = FaceAnalysisOptions()
        mFaceAnalysisOptions?.setFaceSelectionMode(FaceSelectionMode.LARGEST)

        try {
            mFaceAnalyzer?.analyzeOnceAsync(mFaceAnalysisOptions)
            if(VisionSourceHelper.getVisionSourceAccessor() != null){
                Log.i("visionSource", "is not null")
                VisionSourceHelper.getVisionSourceAccessor().addSubscriber {
                    cameraFrame = it.data
                }

            }else{
                Log.i("visionSource", "is null")

            }
        } catch (ex: Exception) {
            ex.printStackTrace()
        }
        mDoneAnalyzing = false
    }

    private fun updateTextView(newText: String) {
        mHandler.post {
            mInstructionsView.text = newText
        }
    }

    private fun displayCameraOnLayout() {
        val previewSize = mVisionSource?.cameraPreviewFormat
        val params = mCameraPreviewLayout.layoutParams as ConstraintLayout.LayoutParams
        params.dimensionRatio = previewSize?.height.toString() + ":" + previewSize?.width
        params.width = ConstraintLayout.LayoutParams.MATCH_CONSTRAINT
        params.matchConstraintDefaultWidth = ConstraintLayout.LayoutParams.MATCH_CONSTRAINT_PERCENT
        params.matchConstraintPercentWidth = 0.8f
        mCameraPreviewLayout.layoutParams = params
    }

    private fun onSubmit(analyzedResult: LivenessResultModel?){
        val gson = Gson()
        val resultIntent = Intent()
        resultIntent.putExtra("result_azure", gson.toJson(analyzedResult))
        setResult(android.app.Activity.RESULT_OK, resultIntent)
        finish()
    }

    private fun onBack(){
        synchronized(this) {
            mBackPressed = true
        }

        setResult(android.app.Activity.RESULT_CANCELED, null)
        finish()
    }

    private fun mapFeedbackToMessage(feedback : FeedbackForFace): String {
        return FaceFeedbackUtils.faceFeedbackToString(feedback)
    }
}