package com.cleancode.liveness_azure_flutter

import android.Manifest
import android.app.Activity
import android.content.Intent
import android.content.pm.PackageManager
import android.provider.Settings.Secure
import android.util.Log
import androidx.core.content.ContextCompat
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import io.flutter.plugin.common.PluginRegistry.ActivityResultListener
import java.util.UUID

/** LivenessAzureFlutterPlugin */
class LivenessAzureFlutterPlugin: FlutterPlugin, MethodCallHandler, ActivityAware, ActivityResultListener {
  private var result: MethodChannel.Result? = null
  private var call: MethodCall? = null

  private lateinit var channel : MethodChannel
  private var activity: Activity? = null
  private val requestCodeLiveness = 1

  override fun onAttachedToEngine(flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
    channel = MethodChannel(flutterPluginBinding.binaryMessenger, "liveness_azure_flutter")
    channel.setMethodCallHandler(this)
  }

  override fun onMethodCall(call: MethodCall, result: Result) {
    this.result = result
    this.call = call

    when ("${call.method}") {
      "initLiveness" -> {
        checkAndRequestCameraPermission()

      }
      "getDeviceUID" -> {
        result?.success(getUniqueUID())

      }
      else -> {
        result.notImplemented()

      }
    }
  }

  private fun getUniqueUID(): String?{
    return activity?.let { context ->
      val deviceId = Secure.getString(context.contentResolver, Secure.ANDROID_ID).toLong(16)
      return UUID(deviceId, deviceId).toString()

    }
  }

  private fun checkAndRequestCameraPermission() {
    activity?.let { context ->
      if (ContextCompat.checkSelfPermission(context, Manifest.permission.CAMERA) != PackageManager.PERMISSION_GRANTED) {
        result?.error("PERMISSION_DENIED", "Camera permission denied", null)
        return

      }

      return launchLiveness(call!!.argument<String>("authTokenSession"), call!!)

    } ?: run {
      result?.error("ACTIVITY_NOT_ATTACHED", "Activity not attached", null)

    }
  }

  private fun launchLiveness(authTokenSession: String?, call: MethodCall){
    if(authTokenSession == null){
      result?.error("MISSING_PARAMS", "Missing authToken or apiKey", null)

    }

    activity?.let {context ->
      val arguments = call.arguments<Map<String, Any>>()
      FaceFeedbackUtils.initialize(arguments)

      val intent = Intent(context, LivenessActivity::class.java)
      intent.putExtra("authTokenSession", authTokenSession);
      context.startActivityForResult(intent, requestCodeLiveness)

    } ?: run {
      result?.error("ACTIVITY_NOT_ATTACHED", "Activity not attached", null)

    }
  }

  override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?): Boolean {
    Log.i("onActivityResult", "called");

    if (requestCode == requestCodeLiveness) {
      if(result == null){
        Log.e("onActivityResult $requestCodeLiveness", "is null");

      }

      when (resultCode) {
        Activity.RESULT_OK -> {
          val resultData = data?.getStringExtra("result_azure")
          result?.success(resultData)

        }
        Activity.RESULT_CANCELED -> {
          result?.error("USER_CANCELLED", "User cancelled the activity", null)
        }

        else -> {
          result?.error("UNKNOWN_ERROR", "Unknown error occurred", null)
        }
      }

      return true
    }

    return false
  }

  override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
    channel.setMethodCallHandler(null)
  }

  override fun onAttachedToActivity(binding: ActivityPluginBinding) {
    activity = binding.activity
    binding.addActivityResultListener(this)
  }

  override fun onDetachedFromActivity() {
    activity = null
  }

  override fun onReattachedToActivityForConfigChanges(binding: ActivityPluginBinding) {
    activity = binding.activity
  }

  override fun onDetachedFromActivityForConfigChanges() {
    activity = null
  }
}
