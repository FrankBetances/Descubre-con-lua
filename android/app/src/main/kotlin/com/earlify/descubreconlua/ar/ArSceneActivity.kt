package com.earlify.descubreconlua.ar

import android.Manifest
import android.app.Activity
import android.content.Context
import android.content.Intent
import android.content.pm.PackageManager
import android.graphics.Canvas
import android.graphics.Color
import android.graphics.DashPathEffect
import android.graphics.Paint
import android.graphics.Path
import android.graphics.PointF
import android.graphics.Typeface
import android.graphics.drawable.GradientDrawable
import android.opengl.GLSurfaceView
import android.opengl.Matrix
import android.os.Build
import android.os.Bundle
import android.os.Handler
import android.os.Looper
import android.os.SystemClock
import android.view.Gravity
import android.view.MotionEvent
import android.view.Surface
import android.view.View
import android.view.WindowManager
import android.widget.FrameLayout
import android.widget.HorizontalScrollView
import android.widget.LinearLayout
import android.widget.TextView
import androidx.activity.ComponentActivity
import androidx.activity.OnBackPressedCallback
import androidx.activity.result.contract.ActivityResultContracts
import androidx.core.content.ContextCompat
import com.google.ar.core.Frame
import com.google.ar.core.Plane
import com.google.ar.core.Pose
import com.google.ar.core.TrackingState
import org.json.JSONArray
import org.json.JSONObject
import kotlin.math.atan2
import kotlin.math.cos
import kotlin.math.sin

/**
 * Escena 3D sobre mesa con ARCore + SetMeshRenderer (portada de ValeriaArSceneActivity, P10.4).
 * Totalmente offline: no guarda imágenes ni vídeo y no solicita fonación.
 */
class ArSceneActivity : ComponentActivity() {

    private lateinit var arSession: ArCoreSession
    private var renderer: ArRenderer? = null
    private var glView: GLSurfaceView? = null
    private var meshRenderer: SetMeshRenderer? = null

    private lateinit var spec: SceneSpec
    private val main = Handler(Looper.getMainLooper())
    private var installRetries = 0
    private var finished = false

    @Volatile private var snapshot: ProjectionSnapshot? = null
    @Volatile private var pendingTap: PointF? = null
    @Volatile private var anchor: com.google.ar.core.Anchor? = null
    @Volatile private var planesFound = false

    private var confirmed = linkedSetOf<String>()
    private var lastEvent: String? = null
    private var anchored = false
    private var tableSeen = false
    private var step = 0
    private var modelShown = true

    @Volatile private var glStep = 0
    @Volatile private var glModelShown = true

    private lateinit var rootLayout: FrameLayout
    private lateinit var overlayView: SceneOverlayCanvasView
    private lateinit var hintTextView: TextView
    private lateinit var chipsContainer: LinearLayout
    private lateinit var controlsRow: LinearLayout

    private val cameraPermission =
        registerForActivityResult(ActivityResultContracts.RequestPermission()) { granted ->
            if (granted) startPipeline() else finishWith("denied")
        }

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        window.addFlags(WindowManager.LayoutParams.FLAG_KEEP_SCREEN_ON)
        spec = SceneSpec.parse(intent.getStringExtra(EXTRA_SPEC))
        arSession = ArCoreSession(this, rear = true)
        meshRenderer = SetMeshRenderer(assets)

        setupUi()

        onBackPressedDispatcher.addCallback(this, object : OnBackPressedCallback(true) {
            override fun handleOnBackPressed() {
                finishWith("completed")
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
        overlayView = SceneOverlayCanvasView(this)
        rootLayout.addView(
            overlayView,
            FrameLayout.LayoutParams(
                FrameLayout.LayoutParams.MATCH_PARENT,
                FrameLayout.LayoutParams.MATCH_PARENT,
            ),
        )

        controlsRow = LinearLayout(this).apply {
            orientation = LinearLayout.HORIZONTAL
            setPadding(24, 24, 24, 16)
        }
        val topLeftLp = FrameLayout.LayoutParams(
            FrameLayout.LayoutParams.WRAP_CONTENT,
            FrameLayout.LayoutParams.WRAP_CONTENT,
            Gravity.TOP or Gravity.START,
        )
        rootLayout.addView(controlsRow, topLeftLp)

        if (spec.title.isNotEmpty()) {
            val titleView = TextView(this).apply {
                text = spec.title
                setTextColor(Color.WHITE)
                textSize = 17f
                setTypeface(Typeface.DEFAULT_BOLD)
                setPadding(24, 14, 24, 14)
                background = GradientDrawable().apply {
                    setColor(0x990B1220.toInt())
                    cornerRadius = 18f
                }
            }
            val topRightLp = FrameLayout.LayoutParams(
                FrameLayout.LayoutParams.WRAP_CONTENT,
                FrameLayout.LayoutParams.WRAP_CONTENT,
                Gravity.TOP or Gravity.END,
            ).apply {
                setMargins(24, 24, 24, 0)
            }
            rootLayout.addView(titleView, topRightLp)
        }

        val bottomBar = LinearLayout(this).apply {
            orientation = LinearLayout.VERTICAL
            setBackgroundColor(0xD20B1220.toInt())
            setPadding(28, 20, 28, 22)
        }
        hintTextView = TextView(this).apply {
            setTextColor(Color.WHITE)
            textSize = 15f
            setPadding(0, 0, 0, 12)
        }
        bottomBar.addView(hintTextView)

        val scroll = HorizontalScrollView(this).apply {
            isHorizontalScrollBarEnabled = false
        }
        chipsContainer = LinearLayout(this).apply {
            orientation = LinearLayout.HORIZONTAL
        }
        scroll.addView(chipsContainer)
        bottomBar.addView(scroll)

        val bottomLp = FrameLayout.LayoutParams(
            FrameLayout.LayoutParams.MATCH_PARENT,
            FrameLayout.LayoutParams.WRAP_CONTENT,
            Gravity.BOTTOM,
        )
        rootLayout.addView(bottomBar, bottomLp)

        setContentView(rootLayout)
        refreshUiState()
    }

    private fun makeChip(label: String, selected: Boolean = false, onClick: () -> Unit): TextView =
        TextView(this).apply {
            text = label
            setTextColor(0xFF0B1220.toInt())
            textSize = 14f
            setTypeface(Typeface.DEFAULT_BOLD)
            setPadding(28, 16, 28, 16)
            background = GradientDrawable().apply {
                setColor(if (selected) 0xFF00C4BE.toInt() else Color.WHITE)
                cornerRadius = 24f
            }
            setOnClickListener { onClick() }
        }

    private fun refreshUiState() {
        controlsRow.removeAllViews()
        controlsRow.addView(makeChip(spec.closeLabel) { finishWith("completed") })
        if (anchored && spec.replaceLabel.isNotEmpty()) {
            controlsRow.addView(makeChip(spec.replaceLabel) {
                anchor?.detach()
                anchor = null
                anchored = false
                refreshUiState()
            }.apply {
                (layoutParams as? LinearLayout.LayoutParams)?.leftMargin = 16
                layoutParams = LinearLayout.LayoutParams(
                    LinearLayout.LayoutParams.WRAP_CONTENT,
                    LinearLayout.LayoutParams.WRAP_CONTENT,
                ).apply { leftMargin = 16 }
            })
        }
        if (anchored && spec.model != null && spec.hideLabel.isNotEmpty()) {
            controlsRow.addView(makeChip(if (modelShown) spec.hideLabel else spec.showLabel) {
                modelShown = !modelShown
                glModelShown = modelShown
                refreshUiState()
            }.apply {
                layoutParams = LinearLayout.LayoutParams(
                    LinearLayout.LayoutParams.WRAP_CONTENT,
                    LinearLayout.LayoutParams.WRAP_CONTENT,
                ).apply { leftMargin = 16 }
            })
        }

        val current = spec.events.firstOrNull { it.id == lastEvent }
        val steps = spec.model?.steps ?: emptyList()
        val playing = step >= steps.size
        hintTextView.text = when {
            !anchored && !tableSeen -> spec.searchHint
            !anchored -> spec.placeHint
            !playing -> steps[step].hint
            current != null -> current.prompt + (if (current.englishPhrase.isNotEmpty()) "   ·   ${spec.luaPrefix}${current.englishPhrase}" else "")
            else -> spec.events.firstOrNull()?.prompt ?: ""
        }

        chipsContainer.removeAllViews()
        if (anchored) {
            if (steps.isNotEmpty()) {
                steps.forEachIndexed { i, st ->
                    val lp = LinearLayout.LayoutParams(
                        LinearLayout.LayoutParams.WRAP_CONTENT,
                        LinearLayout.LayoutParams.WRAP_CONTENT,
                    ).apply { rightMargin = 14 }
                    chipsContainer.addView(makeChip(st.label, selected = step == i) {
                        step = i
                        glStep = i
                        refreshUiState()
                    }, lp)
                }
                val lpPlay = LinearLayout.LayoutParams(
                    LinearLayout.LayoutParams.WRAP_CONTENT,
                    LinearLayout.LayoutParams.WRAP_CONTENT,
                ).apply { rightMargin = 14 }
                chipsContainer.addView(makeChip(spec.playLabel, selected = playing) {
                    step = steps.size
                    glStep = steps.size
                    refreshUiState()
                }, lpPlay)
            }
            if (playing) {
                spec.events.forEach { ev ->
                    val done = ev.id in confirmed
                    val lp = LinearLayout.LayoutParams(
                        LinearLayout.LayoutParams.WRAP_CONTENT,
                        LinearLayout.LayoutParams.WRAP_CONTENT,
                    ).apply { rightMargin = 14 }
                    chipsContainer.addView(makeChip(if (done) "${ev.label} ✓" else ev.label, selected = done) {
                        confirmed.add(ev.id)
                        lastEvent = ev.id
                        refreshUiState()
                    }, lp)
                }
            }
        }
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
        r.setDisplayRotation(displayRotation())
        if (!arSession.resume()) {
            finishWith("aborted", "CAMERA_BUSY")
            return
        }
        gl.onResume()
    }

    private fun onGlFrame(frame: Frame) {
        val camera = frame.camera
        if (camera.trackingState != TrackingState.TRACKING) return
        val session = arSession.session ?: return

        if (!planesFound) {
            planesFound = session.getAllTrackables(Plane::class.java)
                .any { it.trackingState == TrackingState.TRACKING && it.type == Plane.Type.HORIZONTAL_UPWARD_FACING }
            if (planesFound) {
                runOnUiThread {
                    tableSeen = true
                    refreshUiState()
                }
            }
        }

        val tap = pendingTap
        if (tap != null && anchor == null) {
            pendingTap = null
            val hit = frame.hitTest(tap.x, tap.y).firstOrNull { h ->
                val t = h.trackable
                t is Plane && t.type == Plane.Type.HORIZONTAL_UPWARD_FACING && t.isPoseInPolygon(h.hitPose)
            }
            if (hit != null) {
                val hp = hit.hitPose
                val cp = camera.pose
                val yaw = atan2(cp.tx() - hp.tx(), cp.tz() - hp.tz())
                val q = floatArrayOf(0f, sin(yaw / 2f), 0f, cos(yaw / 2f))
                anchor = session.createAnchor(Pose(floatArrayOf(hp.tx(), hp.ty(), hp.tz()), q))
                runOnUiThread {
                    anchored = true
                    refreshUiState()
                }
            }
        }

        val a = anchor ?: run {
            snapshot = null
            return
        }
        if (a.trackingState != TrackingState.TRACKING) return
        val view = FloatArray(16)
        val proj = FloatArray(16)
        val model = FloatArray(16)
        camera.getViewMatrix(view, 0)
        camera.getProjectionMatrix(proj, 0, 0.05f, 20f)
        a.pose.toMatrix(model, 0)
        val vp = FloatArray(16)
        val mvp = FloatArray(16)
        Matrix.multiplyMM(vp, 0, proj, 0, view, 0)
        Matrix.multiplyMM(mvp, 0, vp, 0, model, 0)
        snapshot = ProjectionSnapshot(mvp)
        drawSetModel(vp, model)
        runOnUiThread { overlayView.invalidate() }
    }

    private fun drawSetModel(viewProj: FloatArray, anchorModel: FloatArray) {
        val m = spec.model ?: return
        if (!glModelShown || m.steps.isEmpty()) return
        val r = meshRenderer ?: return
        val playing = glStep >= m.steps.size
        val st = m.steps[glStep.coerceIn(0, m.steps.size - 1)]
        if (!r.begin()) return
        val bob = (0.006f * sin(SystemClock.uptimeMillis() / 380.0)).toFloat()
        val pm = FloatArray(16)
        for (pc in st.pieces) {
            val lift = if (!playing && !pc.placed) bob else 0f
            Matrix.translateM(pm, 0, anchorModel, 0, pc.x, pc.y + lift, pc.z)
            val alpha = if (playing) 0.45f else if (pc.placed) 0.80f else 1f
            r.draw(pc.mesh, viewProj, pm, pc.r, pc.g, pc.b, alpha)
        }
        for (l in st.lua) {
            Matrix.translateM(pm, 0, anchorModel, 0, l.x, l.y, l.z)
            Matrix.rotateM(pm, 0, l.rotDeg, 0f, 1f, 0f)
            for (part in m.luaParts) {
                r.draw(part.mesh, viewProj, pm, part.r, part.g, part.b, if (playing) 0.55f else 0.92f)
            }
        }
        r.end()
    }

    private inner class SceneOverlayCanvasView(context: Context) : View(context) {
        private val linePaint = Paint(Paint.ANTI_ALIAS_FLAG).apply {
            style = Paint.Style.STROKE
            strokeWidth = 6f
        }
        private val fillPaint = Paint(Paint.ANTI_ALIAS_FLAG).apply {
            style = Paint.Style.FILL
        }
        private val textPaint = Paint(Paint.ANTI_ALIAS_FLAG).apply {
            color = Color.WHITE
            textSize = 34f
            typeface = Typeface.DEFAULT_BOLD
            setShadowLayer(6f, 0f, 2f, Color.BLACK)
            textAlign = Paint.Align.CENTER
        }

        override fun onTouchEvent(event: MotionEvent): Boolean {
            if (event.action == MotionEvent.ACTION_UP && anchor == null) {
                pendingTap = PointF(event.x, event.y)
                return true
            }
            return super.onTouchEvent(event)
        }

        override fun onDraw(canvas: Canvas) {
            super.onDraw(canvas)
            val snap = snapshot ?: return
            val w = width.toFloat()
            val h = height.toFloat()
            val steps = spec.model?.steps ?: emptyList()
            val playing = step >= steps.size
            if (!playing && modelShown && steps.isNotEmpty()) {
                steps[step].arrows.forEach { (a, b) ->
                    val pa = snap.project(a[0], a[2], w, h, a[1]) ?: return@forEach
                    val pb = snap.project(b[0], b[2], w, h, b[1]) ?: return@forEach
                    drawArrow(canvas, pa, pb, 0xFFFFB547.toInt())
                }
            }
            if (playing) {
                val t = SystemClock.uptimeMillis() / 1000.0
                spec.shapes.filter { it.visible(confirmed, lastEvent) }.forEach { s ->
                    drawShape(canvas, s, snap, w, h, t)
                }
            }
        }

        private fun drawArrow(canvas: Canvas, a: PointF, b: PointF, color: Int) {
            linePaint.color = color
            linePaint.strokeWidth = 10f
            linePaint.pathEffect = null
            canvas.drawLine(a.x, a.y, b.x, b.y, linePaint)
            val ang = atan2((b.y - a.y).toDouble(), (b.x - a.x).toDouble())
            for (side in listOf(-0.5, 0.5)) {
                val px = (b.x - 34f * cos(ang + side)).toFloat()
                val py = (b.y - 34f * sin(ang + side)).toFloat()
                canvas.drawLine(b.x, b.y, px, py, linePaint)
            }
        }

        private fun drawShape(
            canvas: Canvas,
            s: SceneShape,
            snap: ProjectionSnapshot,
            w: Float,
            h: Float,
            t: Double,
        ) {
            val baseColor = when (s.style) {
                "warn" -> 0xFFFFB547.toInt()
                "piece" -> 0xFFB9B2A6.toInt()
                else -> 0xFF00C4BE.toInt()
            }
            val dashed = if (s.style == "ghost" || s.style == "warn") {
                DashPathEffect(floatArrayOf(18f, 14f), 0f)
            } else {
                null
            }
            when (s.kind) {
                "tile" -> {
                    val (x, z) = s.pts.firstOrNull() ?: return
                    val corners = listOf(x to z, x + s.w to z, x + s.w to z + s.d, x to z + s.d)
                        .map { snap.project(it.first, it.second, w, h, s.y) ?: return }
                    val path = Path().apply {
                        moveTo(corners[0].x, corners[0].y)
                        corners.drop(1).forEach { lineTo(it.x, it.y) }
                        close()
                    }
                    if (s.style == "piece") {
                        fillPaint.color = 0xCCEFEAE0.toInt()
                        canvas.drawPath(path, fillPaint)
                    } else if (s.style == "light") {
                        fillPaint.color = 0x4700C4BE
                        canvas.drawPath(path, fillPaint)
                    }
                    linePaint.color = baseColor
                    linePaint.strokeWidth = 5f
                    linePaint.pathEffect = dashed
                    canvas.drawPath(path, linePaint)
                    if (s.text.isNotEmpty()) {
                        snap.project(x + s.w / 2, z + s.d + 0.02f, w, h, s.y)?.let {
                            canvas.drawText(s.text, it.x, it.y, textPaint)
                        }
                    }
                }
                "circle", "rings" -> {
                    val (x, z) = s.pts.firstOrNull() ?: return
                    val rings = if (s.kind == "rings") 3 else 1
                    for (k in 0 until rings) {
                        val grow = if (s.kind == "rings") (((t * 0.6) + k / 3.0) % 1.0).toFloat() else 0f
                        val rr = s.r * (1f + grow * 1.6f)
                        val pts = (0..32).map { i ->
                            val a = i / 32.0 * 2 * Math.PI
                            snap.project(x + rr * cos(a).toFloat(), z + rr * sin(a).toFloat(), w, h, s.y)
                                ?: return
                        }
                        val path = Path().apply {
                            moveTo(pts[0].x, pts[0].y)
                            pts.drop(1).forEach { lineTo(it.x, it.y) }
                            close()
                        }
                        val alpha = if (s.kind == "rings") ((1f - grow) * 255).toInt() else 255
                        linePaint.color = (baseColor and 0x00FFFFFF) or (alpha shl 24)
                        linePaint.strokeWidth = 5f
                        linePaint.pathEffect = dashed
                        canvas.drawPath(path, linePaint)
                    }
                    if (s.text.isNotEmpty()) {
                        snap.project(x, z + s.r + 0.025f, w, h, s.y)?.let {
                            canvas.drawText(s.text, it.x, it.y, textPaint)
                        }
                    }
                }
                "line", "flow" -> {
                    val pts = s.pts.map { snap.project(it.first, it.second, w, h, s.y) ?: return }
                    if (pts.size < 2) return
                    val path = Path().apply {
                        moveTo(pts[0].x, pts[0].y)
                        pts.drop(1).forEach { lineTo(it.x, it.y) }
                    }
                    linePaint.color = baseColor
                    linePaint.strokeWidth = if (s.kind == "flow") 14f else 6f
                    linePaint.pathEffect = if (s.kind == "flow") {
                        DashPathEffect(floatArrayOf(36f, 22f), (-(t * 120.0) % 58.0).toFloat())
                    } else {
                        dashed
                    }
                    canvas.drawPath(path, linePaint)
                }
                "arrow" -> {
                    if (s.pts.size < 2) return
                    val a = snap.project(s.pts[0].first, s.pts[0].second, w, h, s.y) ?: return
                    val b = snap.project(s.pts[1].first, s.pts[1].second, w, h, s.y) ?: return
                    drawArrow(canvas, a, b, baseColor)
                }
                "label" -> {
                    val (x, z) = s.pts.firstOrNull() ?: return
                    snap.project(x, z, w, h, s.y)?.let { canvas.drawText(s.text, it.x, it.y, textPaint) }
                }
            }
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
        anchor?.detach()
        anchor = null
        arSession.close()
        super.onDestroy()
    }

    private fun finishWith(outcome: String, reason: String? = null) {
        if (finished) return
        finished = true
        val payload = JSONObject()
            .put("outcome", outcome)
            .put("confirmed", JSONArray(confirmed.toList()))
        if (reason != null) payload.put("reason", reason)
        setResult(Activity.RESULT_OK, Intent().putExtra(EXTRA_RESULT, payload.toString()))
        finish()
    }

    @Suppress("DEPRECATION")
    private fun displayRotation(): Int =
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.R) display?.rotation ?: Surface.ROTATION_0
        else windowManager.defaultDisplay.rotation

    companion object {
        const val EXTRA_SPEC = "lua.ar.sceneSpec"
        const val EXTRA_RESULT = "lua.ar.result"

        fun intent(context: Context, specJson: String): Intent =
            Intent(context, ArSceneActivity::class.java).putExtra(EXTRA_SPEC, specJson)
    }
}

private class ProjectionSnapshot(private val mvp: FloatArray) {
    fun project(x: Float, z: Float, w: Float, h: Float, y: Float = 0f): PointF? {
        val out = FloatArray(4)
        Matrix.multiplyMV(out, 0, mvp, 0, floatArrayOf(x, y, z, 1f), 0)
        if (out[3] <= 0.0001f) return null
        val nx = out[0] / out[3]
        val ny = out[1] / out[3]
        return PointF((nx * 0.5f + 0.5f) * w, (1f - (ny * 0.5f + 0.5f)) * h)
    }
}

private class SceneEvent(val id: String, val label: String, val prompt: String, val englishPhrase: String)

private class SceneShape(
    val kind: String,
    val style: String,
    val pts: List<Pair<Float, Float>>,
    val w: Float,
    val d: Float,
    val r: Float,
    val y: Float,
    val text: String,
    val after: String?,
    val last: Set<String>,
) {
    fun visible(confirmed: Set<String>, lastEvent: String?): Boolean = when {
        last.isNotEmpty() -> lastEvent != null && lastEvent in last
        after != null -> after in confirmed
        else -> true
    }

    companion object {
        fun parse(o: JSONObject): SceneShape {
            val p = o.optJSONArray("pts") ?: JSONArray()
            val pts = (0 until p.length()).map { i ->
                val q = p.getJSONArray(i)
                q.getDouble(0).toFloat() to q.getDouble(1).toFloat()
            }
            val l = o.optJSONArray("last") ?: JSONArray()
            return SceneShape(
                kind = o.optString("kind"),
                style = o.optString("style", "piece"),
                pts = pts,
                w = o.optDouble("w", 0.0).toFloat(),
                d = o.optDouble("d", 0.0).toFloat(),
                r = o.optDouble("r", 0.0).toFloat(),
                y = o.optDouble("y", 0.0).toFloat(),
                text = o.optString("text"),
                after = if (o.has("after")) o.optString("after") else null,
                last = (0 until l.length()).map { l.getString(it) }.toSet(),
            )
        }
    }
}

private class SetPiece(val mesh: String, val r: Float, val g: Float, val b: Float, val x: Float, val y: Float, val z: Float, val placed: Boolean)
private class SetLua(val x: Float, val y: Float, val z: Float, val rotDeg: Float)
private class SetStep(val label: String, val hint: String, val pieces: List<SetPiece>, val arrows: List<Pair<FloatArray, FloatArray>>, val lua: List<SetLua>)

private class SetModel(val steps: List<SetStep>, val luaParts: List<SetPiece>) {
    companion object {
        private fun f(a: JSONArray, i: Int) = a.optDouble(i, 0.0).toFloat()
        private fun piece(o: JSONObject): SetPiece {
            val c = o.optJSONArray("rgb") ?: JSONArray()
            val p = o.optJSONArray("p") ?: JSONArray()
            return SetPiece(o.optString("m"), f(c, 0), f(c, 1), f(c, 2), f(p, 0), f(p, 1), f(p, 2), o.optBoolean("placed"))
        }
        private fun vec(a: JSONArray) = floatArrayOf(f(a, 0), f(a, 1), f(a, 2))
        fun parse(o: JSONObject): SetModel {
            val st = o.optJSONArray("steps") ?: JSONArray()
            val lp = o.optJSONArray("luaParts") ?: JSONArray()
            return SetModel(
                steps = (0 until st.length()).map { i ->
                    val s = st.getJSONObject(i)
                    val pcs = s.optJSONArray("pieces") ?: JSONArray()
                    val ars = s.optJSONArray("arrows") ?: JSONArray()
                    val lus = s.optJSONArray("lua") ?: JSONArray()
                    SetStep(
                        label = s.optString("label"),
                        hint = s.optString("hint"),
                        pieces = (0 until pcs.length()).map { piece(pcs.getJSONObject(it)) },
                        arrows = (0 until ars.length()).map { k ->
                            val a = ars.getJSONArray(k)
                            vec(a.getJSONArray(0)) to vec(a.getJSONArray(1))
                        },
                        lua = (0 until lus.length()).map { k ->
                            val l = lus.getJSONObject(k)
                            val p = l.optJSONArray("p") ?: JSONArray()
                            SetLua(f(p, 0), f(p, 1), f(p, 2), l.optDouble("r", 0.0).toFloat())
                        },
                    )
                },
                luaParts = (0 until lp.length()).map { piece(lp.getJSONObject(it)) },
            )
        }
    }
}

private class SceneSpec(
    val title: String,
    val placeHint: String,
    val searchHint: String,
    val closeLabel: String,
    val replaceLabel: String,
    val luaPrefix: String,
    val events: List<SceneEvent>,
    val shapes: List<SceneShape>,
    val model: SetModel?,
    val playLabel: String,
    val hideLabel: String,
    val showLabel: String,
) {
    companion object {
        fun parse(raw: String?): SceneSpec {
            val o = try { JSONObject(raw ?: "{}") } catch (_: Throwable) { JSONObject() }
            val ev = o.optJSONArray("events") ?: JSONArray()
            val sh = o.optJSONArray("shapes") ?: JSONArray()
            return SceneSpec(
                title = o.optString("title"),
                placeHint = o.optString("placeHint"),
                searchHint = o.optString("searchHint"),
                closeLabel = o.optString("closeLabel", "OK"),
                replaceLabel = o.optString("replaceLabel"),
                luaPrefix = o.optString("luaPrefix"),
                events = (0 until ev.length()).map { i ->
                    val e = ev.getJSONObject(i)
                    SceneEvent(
                        e.optString("id"),
                        e.optString("label"),
                        e.optString("prompt"),
                        e.optString("englishPhrase"),
                    )
                },
                shapes = (0 until sh.length()).map { i -> SceneShape.parse(sh.getJSONObject(i)) },
                model = o.optJSONObject("model")?.let { SetModel.parse(it) },
                playLabel = o.optString("playLabel", "▶"),
                hideLabel = o.optString("hideLabel"),
                showLabel = o.optString("showLabel"),
            )
        }
    }
}
