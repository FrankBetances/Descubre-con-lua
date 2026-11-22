package com.earlify.descubreconlua.ar

import android.app.Activity
import android.content.Intent
import android.content.pm.PackageManager
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel

/**
 * Canal nativo de Realidad Aumentada para Flutter (`com.earlify.descubreconlua/ar`).
 */
class ArBridge(private val activity: Activity) {

    private var channel: MethodChannel? = null
    private var pendingResult: MethodChannel.Result? = null

    fun attach(flutterEngine: FlutterEngine) {
        val ch = MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL)
        channel = ch
        ch.setMethodCallHandler { call, result ->
            when (call.method) {
                "checkAvailability" -> handleCheckAvailability(result)
                "openScene" -> handleLaunch(call, result, isFace = false)
                "openFaceActivity" -> handleLaunch(call, result, isFace = true)
                else -> result.notImplemented()
            }
        }
    }

    private fun handleCheckAvailability(result: MethodChannel.Result) {
        val pm = activity.packageManager
        val hasCamera = pm.hasSystemFeature(PackageManager.FEATURE_CAMERA_ANY)
        val hasFrontCamera = pm.hasSystemFeature(PackageManager.FEATURE_CAMERA_FRONT)
        val arCoreSupported = ArCoreSession.isArCoreSupported(activity)
        val modelIntact = FaceSignalEngine.verifyBundledModelSha256(activity)
        result.success(
            mapOf(
                "available" to (hasCamera && arCoreSupported),
                "hasCamera" to hasCamera,
                "hasFrontCamera" to hasFrontCamera,
                "arCoreSupported" to arCoreSupported,
                "modelShaOk" to modelIntact,
                "reason" to when {
                    !hasCamera -> "NO_CAMERA"
                    !arCoreSupported -> "DEVICE_NOT_SUPPORTED"
                    else -> "OK"
                },
            )
        )
    }

    private fun handleLaunch(call: MethodCall, result: MethodChannel.Result, isFace: Boolean) {
        if (pendingResult != null) {
            result.error("E_AR_BUSY", "Ya hay una sesión de RA abierta", null)
            return
        }
        val specJson = call.argument<String>("specJson") ?: "{}"
        val pm = activity.packageManager
        val hasCamera = pm.hasSystemFeature(PackageManager.FEATURE_CAMERA_ANY)
        if (!hasCamera || !ArCoreSession.isArCoreSupported(activity)) {
            val reason = if (!hasCamera) "NO_CAMERA" else "DEVICE_NOT_SUPPORTED"
            result.success("""{"outcome":"unsupported","reason":"$reason"}""")
            return
        }
        pendingResult = result
        val intent = if (isFace) {
            ArFaceActivity.intent(activity, specJson)
        } else {
            ArSceneActivity.intent(activity, specJson)
        }
        try {
            activity.startActivityForResult(intent, REQUEST_CODE)
        } catch (t: Throwable) {
            pendingResult = null
            result.success("""{"outcome":"unsupported","reason":"LAUNCH_ERROR"}""")
        }
    }

    fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?): Boolean {
        if (requestCode != REQUEST_CODE) return false
        val pending = pendingResult ?: return true
        pendingResult = null
        val payload = data?.getStringExtra(ArSceneActivity.EXTRA_RESULT)
            ?: """{"outcome":"${if (resultCode == Activity.RESULT_OK) "completed" else "aborted"}"}"""
        pending.success(payload)
        return true
    }

    fun detach() {
        pendingResult = null
        channel?.setMethodCallHandler(null)
        channel = null
    }

    companion object {
        const val CHANNEL = "com.earlify.descubreconlua/ar"
        private const val REQUEST_CODE = 9811
    }
}
