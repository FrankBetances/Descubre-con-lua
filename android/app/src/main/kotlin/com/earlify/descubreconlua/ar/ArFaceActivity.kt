package com.earlify.descubreconlua.ar

import android.Manifest
import android.app.Activity
import android.content.Context
import android.content.Intent
import android.content.pm.PackageManager
import android.graphics.Color
import android.graphics.Typeface
import android.graphics.drawable.GradientDrawable
import android.hardware.camera2.CameraCharacteristics
import android.hardware.camera2.CameraManager
import android.opengl.GLSurfaceView
import android.os.Build
import android.os.Bundle
import android.os.Handler
import android.os.Looper
import android.view.Gravity
import android.view.Surface
import android.view.WindowManager
import android.widget.FrameLayout
import android.widget.LinearLayout
import android.widget.ProgressBar
import android.widget.TextView
import androidx.activity.ComponentActivity
import androidx.activity.OnBackPressedCallback
import androidx.activity.result.contract.ActivityResultContracts
import androidx.core.content.ContextCompat
import com.google.ar.core.Frame
import org.json.JSONObject

/**
 * Actividad frontal con espejo RA y modelo GLB para gestos faciales en inglés
 * (L01/L07, ar1–ar6, portado de Valeria para P10.4).
 *
 * Todo corre en memoria volátil: ni guarda fotos/vídeo/landmarks ni pide al
 * niño que hable o repita.
 */
class ArFaceActivity : ComponentActivity() {

    private val arSession = ArCoreSession(this, rear = false)
    private var renderer: ArRenderer? = null
    private var glView: GLSurfaceView? = null
    private var engine: FaceSignalEngine? = null
    private var stage: FilamentStageView? = null

    private val main = Handler(Looper.getMainLooper())
    private var installRetries = 0
    private var finished = false
    private var sensorRotation = 270
    private var celebrated = false
    private var charge = 0f

    private var titleStr = ""
    private var adultHint = ""
    private var englishPhrase = ""
    private var closeLabel = "OK"
    private var gestureMode = "smile"
    private var modelAsset = "models/lua.glb"
    private var animName = "celebrate"

    private lateinit var rootLayout: FrameLayout
    private lateinit var progressBar: ProgressBar
    private lateinit var statusLabel: TextView

    private val cameraPermission =
        registerForActivityResult(ActivityResultContracts.RequestPermission()) { granted ->
            if (granted) startPipeline() else finishWith("denied")
        }

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        window.addFlags(WindowManager.LayoutParams.FLAG_KEEP_SCREEN_ON)
        val raw = intent.getStringExtra(EXTRA_SPEC)
        val obj = runCatching { JSONObject(raw ?: "{}") }.getOrDefault(JSONObject())
        titleStr = obj.optString("title")
        adultHint = obj.optString("adultHint")
        englishPhrase = obj.optString("englishPhrase")
        closeLabel = obj.optString("closeLabel", "OK")
        gestureMode = obj.optString("gestureMode", "smile")
        modelAsset = obj.optString("modelAsset", "models/lua.glb")
        animName = obj.optString("animation", "celebrate")
        sensorRotation = frontCameraSensorOrientation()

        setupUi()

        onBackPressedDispatcher.addCallback(this, object : OnBackPressedCallback(true) {
            override fun handleOnBackPressed() {
                finishWith(if (celebrated) "completed" else "aborted")
            }
        })

        if (ContextCompat.checkSelfPermission(this, Manifest.permission.CAMERA) ==
            PackageManager.PERMISSION_GRANTED
        ) {
            startPipeline()
        } else {
            cameraPermission.launch(Manifest.permission.CAMERA)
        }
    }

    private fun setupUi() {
        rootLayout = FrameLayout(this)

        val closeBtn = TextView(this).apply {
            text = closeLabel
            setTextColor(0xFF0B1220.toInt())
            textSize = 15f
            setTypeface(Typeface.DEFAULT_BOLD)
            setPadding(28, 16, 28, 16)
            background = GradientDrawable().apply {
                setColor(Color.WHITE)
                cornerRadius = 24f
            }
            setOnClickListener { finishWith(if (celebrated) "completed" else "aborted") }
        }
        rootLayout.addView(
            closeBtn,
            FrameLayout.LayoutParams(
                FrameLayout.LayoutParams.WRAP_CONTENT,
                FrameLayout.LayoutParams.WRAP_CONTENT,
                Gravity.TOP or Gravity.START,
            ).apply { setMargins(24, 24, 0, 0) },
        )

        if (titleStr.isNotEmpty()) {
            val titleView = TextView(this).apply {
                text = titleStr
                setTextColor(Color.WHITE)
                textSize = 17f
                setTypeface(Typeface.DEFAULT_BOLD)
                setPadding(24, 14, 24, 14)
                background = GradientDrawable().apply {
                    setColor(0x990B1220.toInt())
                    cornerRadius = 18f
                }
            }
            rootLayout.addView(
                titleView,
                FrameLayout.LayoutParams(
                    FrameLayout.LayoutParams.WRAP_CONTENT,
                    FrameLayout.LayoutParams.WRAP_CONTENT,
                    Gravity.TOP or Gravity.END,
                ).apply { setMargins(0, 24, 24, 0) },
            )
        }

        val bottomPanel = LinearLayout(this).apply {
            orientation = LinearLayout.VERTICAL
            setBackgroundColor(0xD20B1220.toInt())
            setPadding(28, 18, 28, 22)
        }
        if (englishPhrase.isNotEmpty()) {
            bottomPanel.addView(TextView(this).apply {
                text = "Lúa: «$englishPhrase»"
                setTextColor(0xFF00C4BE.toInt())
                textSize = 18f
                setTypeface(Typeface.DEFAULT_BOLD)
                setPadding(0, 0, 0, 6)
            })
        }
        statusLabel = TextView(this).apply {
            text = adultHint
            setTextColor(Color.WHITE)
            textSize = 15f
            setPadding(0, 0, 0, 10)
        }
        bottomPanel.addView(statusLabel)

        progressBar = ProgressBar(this, null, android.R.attr.progressBarStyleHorizontal).apply {
            max = 100
            progress = 0
        }
        bottomPanel.addView(progressBar)

        rootLayout.addView(
            bottomPanel,
            FrameLayout.LayoutParams(
                FrameLayout.LayoutParams.MATCH_PARENT,
                FrameLayout.LayoutParams.WRAP_CONTENT,
                Gravity.BOTTOM,
            ),
        )
        setContentView(rootLayout)
    }

    private fun startPipeline() {
        if (isFinishing || isDestroyed || glView != null) return
        if (!arSession.ensureCreated()) {
            val reason = arSession.unavailable
            if (reason == null && installRetries < 4) {
                installRetries++
                main.postDelayed({ startPipeline() }, 2_500L)
                return
            }
            finishWith("unsupported", reason?.name ?: "DEVICE_NOT_SUPPORTED")
            return
        }

        engine = FaceSignalEngine(
            context = this,
            onFaceLost = {
                main.post {
                    charge = (charge - 0.04f).coerceAtLeast(0f)
                    progressBar.progress = (charge * 100).toInt()
                }
            },
            onSignals = { sig ->
                val raw = GestureDetector.scoreFor(gestureMode, sig)
                main.post {
                    if (!celebrated) {
                        charge = if (raw >= 0.42f) {
                            (charge + 0.08f).coerceAtMost(1f)
                        } else {
                            (charge - 0.03f).coerceAtLeast(0f)
                        }
                        stage?.setProgress(charge)
                        progressBar.progress = (charge * 100).toInt()
                        if (charge >= 1f) {
                            celebrated = true
                            stage?.playAnimation(animName)
                            statusLabel.text = "$adultHint ✓"
                        }
                    }
                }
            },
        )

        val r = ArRenderer(
            session = arSession,
            onFrame = { frame -> onGlFrame(frame) },
            onGlError = { runOnUiThread { finishWith("aborted", "GL_ERROR") } },
        )
        renderer = r
        val gl = GLSurfaceView(this).apply {
            preserveEGLContextOnPause = true
            setEGLContextClientVersion(2)
            setEGLConfigChooser(8, 8, 8, 8, 16, 0)
            setRenderer(r)
            renderMode = GLSurfaceView.RENDERMODE_CONTINUOUSLY
        }
        glView = gl
        rootLayout.addView(
            gl,
            0,
            FrameLayout.LayoutParams(
                FrameLayout.LayoutParams.MATCH_PARENT,
                FrameLayout.LayoutParams.MATCH_PARENT,
            ),
        )

        val stageView = FilamentStageView(this)
        stage = stageView
        rootLayout.addView(
            stageView.createTextureView(modelAsset),
            1,
            FrameLayout.LayoutParams(
                FrameLayout.LayoutParams.MATCH_PARENT,
                FrameLayout.LayoutParams.MATCH_PARENT,
            ),
        )

        r.setDisplayRotation(displayRotation())
        if (!arSession.resume()) {
            finishWith("aborted", "CAMERA_BUSY")
            return
        }
        gl.onResume()
    }

    private fun onGlFrame(frame: Frame) {
        if (arSession.trackedFace() == null) return
        val image = arSession.acquireImage(frame) ?: return
        image.use { img ->
            val rot = (sensorRotation + displayDegrees()) % 360
            engine?.analyze(img, rot, mirror = true, tCaptureUs = frame.timestamp)
        }
    }

    override fun onResume() {
        super.onResume()
        if (glView != null) {
            if (arSession.resume()) glView?.onResume() else finishWith("aborted", "CAMERA_BUSY")
        }
    }

    override fun onPause() {
        super.onPause()
        glView?.onPause()
        arSession.pause()
    }

    override fun onDestroy() {
        main.removeCallbacksAndMessages(null)
        engine?.close()
        engine = null
        stage?.release()
        stage = null
        arSession.close()
        super.onDestroy()
    }

    private fun finishWith(outcome: String, reason: String? = null) {
        if (finished) return
        finished = true
        val payload = JSONObject()
            .put("outcome", outcome)
            .put("gestureDone", celebrated)
        if (reason != null) payload.put("reason", reason)
        setResult(Activity.RESULT_OK, Intent().putExtra(ArSceneActivity.EXTRA_RESULT, payload.toString()))
        finish()
    }

    @Suppress("DEPRECATION")
    private fun displayRotation(): Int =
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.R) display?.rotation ?: Surface.ROTATION_0
        else windowManager.defaultDisplay.rotation

    private fun displayDegrees(): Int = when (displayRotation()) {
        Surface.ROTATION_90 -> 90
        Surface.ROTATION_180 -> 180
        Surface.ROTATION_270 -> 270
        else -> 0
    }

    private fun frontCameraSensorOrientation(): Int = runCatching {
        val cm = getSystemService(Context.CAMERA_SERVICE) as CameraManager
        for (id in cm.cameraIdList) {
            val ch = cm.getCameraCharacteristics(id)
            if (ch.get(CameraCharacteristics.LENS_FACING) == CameraCharacteristics.LENS_FACING_FRONT) {
                return@runCatching ch.get(CameraCharacteristics.SENSOR_ORIENTATION) ?: 270
            }
        }
        270
    }.getOrDefault(270)

    companion object {
        const val EXTRA_SPEC = "lua.ar.faceSpec"
        fun intent(context: Context, specJson: String): Intent =
            Intent(context, ArFaceActivity::class.java).putExtra(EXTRA_SPEC, specJson)
    }
}
