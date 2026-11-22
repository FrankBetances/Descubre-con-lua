package com.earlify.descubreconlua.ar

import android.content.Context
import android.graphics.Bitmap
import android.graphics.BitmapFactory
import android.graphics.ImageFormat
import android.graphics.Matrix
import android.graphics.Rect
import android.graphics.YuvImage
import android.media.Image
import android.os.SystemClock
import com.google.mediapipe.framework.image.BitmapImageBuilder
import com.google.mediapipe.tasks.core.BaseOptions
import com.google.mediapipe.tasks.core.Delegate
import com.google.mediapipe.tasks.vision.core.RunningMode
import com.google.mediapipe.tasks.vision.facelandmarker.FaceLandmarker
import com.google.mediapipe.tasks.vision.facelandmarker.FaceLandmarkerResult
import java.io.ByteArrayOutputStream
import java.security.MessageDigest
import kotlin.math.abs
import kotlin.math.max

/**
 * Señal facial instantánea en memoria (portada de Valeria, P10.4).
 *
 * Política estricta de privacidad:
 * 1. El frame nunca sale del dispositivo (cero permisos de red).
 * 2. Nunca se escriben imágenes, vídeos ni puntos faciales en disco.
 * 3. Toda conversión se recicla en el mismo frame; ningún resultado se persiste.
 */
data class FaceSignals(
    val blendshapes: Map<String, Float>,
    val yawDeg: Float,
    val pitchDeg: Float,
    val trackingQuality: Float,
) {
    fun blend(key: String): Float = blendshapes[key] ?: 0f
}

object GestureDetector {
    const val MOUTH_PUCKER = "mouthPucker"
    const val MOUTH_FUNNEL = "mouthFunnel"
    const val JAW_OPEN = "jawOpen"
    const val MOUTH_SMILE_LEFT = "mouthSmileLeft"
    const val MOUTH_SMILE_RIGHT = "mouthSmileRight"
    const val CHEEK_PUFF = "cheekPuff"
    const val EYE_WIDE_LEFT = "eyeWideLeft"
    const val EYE_WIDE_RIGHT = "eyeWideRight"

    /** Evaluates normalized progress 0..1 for playful facial gesture exercises (ar1..ar6). */
    fun scoreFor(mode: String, signals: FaceSignals): Float = when (mode) {
        "jaw_open", "ar1_open" -> signals.blend(JAW_OPEN).coerceIn(0f, 1f)
        "pucker", "ar1" -> max(signals.blend(MOUTH_PUCKER), signals.blend(MOUTH_FUNNEL) * 0.85f).coerceIn(0f, 1f)
        "smile", "ar6" -> ((signals.blend(MOUTH_SMILE_LEFT) + signals.blend(MOUTH_SMILE_RIGHT)) * 0.5f).coerceIn(0f, 1f)
        "big_eyes", "ar3" -> ((signals.blend(EYE_WIDE_LEFT) + signals.blend(EYE_WIDE_RIGHT)) * 0.5f).coerceIn(0f, 1f)
        "cheek_puff", "ar4" -> signals.blend(CHEEK_PUFF).coerceIn(0f, 1f)
        "turn_head", "ar2" -> (abs(signals.yawDeg) / 22f).coerceIn(0f, 1f)
        "ar5" -> max(signals.blend(JAW_OPEN), (signals.blend(MOUTH_SMILE_LEFT) + signals.blend(MOUTH_SMILE_RIGHT)) * 0.5f).coerceIn(0f, 1f)
        else -> ((signals.blend(MOUTH_SMILE_LEFT) + signals.blend(MOUTH_SMILE_RIGHT)) * 0.5f).coerceIn(0f, 1f)
    }
}

class FaceSignalEngine(
    context: Context,
    private val onFaceLost: () -> Unit = {},
    private val onSignals: (FaceSignals) -> Unit,
) {

    private var landmarker: FaceLandmarker? = null
    private val lock = Any()
    @Volatile private var closed = false
    @Volatile private var inferenceStartedMs = 0L

    val isReady: Boolean get() = landmarker != null

    init {
        if (verifyBundledModelSha256(context)) {
            landmarker = build(context, Delegate.GPU) ?: build(context, Delegate.CPU)
        }
    }

    private fun build(context: Context, delegate: Delegate): FaceLandmarker? = try {
        val base = BaseOptions.builder()
            .setModelAssetPath(MODEL_ASSET)
            .setDelegate(delegate)
            .build()
        val options = FaceLandmarker.FaceLandmarkerOptions.builder()
            .setBaseOptions(base)
            .setRunningMode(RunningMode.LIVE_STREAM)
            .setNumFaces(1)
            .setOutputFaceBlendshapes(true)
            .setOutputFacialTransformationMatrixes(true)
            .setMinTrackingConfidence(0.5f)
            .setResultListener { result, _ -> dispatch(result) }
            .setErrorListener { inferenceStartedMs = 0L }
            .build()
        FaceLandmarker.createFromOptions(context, options)
    } catch (_: Throwable) {
        null
    }

    fun analyze(image: Image, rotationDegrees: Int, mirror: Boolean, tCaptureUs: Long) {
        if (closed) return
        try {
            val now = SystemClock.elapsedRealtime()
            val busy = inferenceStartedMs
            if (busy != 0L && now - busy < STALE_INFERENCE_MS) return

            val bitmap = image.toUprightBitmap(rotationDegrees, mirror) ?: return
            val mpImage = BitmapImageBuilder(bitmap).build()
            inferenceStartedMs = now
            synchronized(lock) {
                val lm = landmarker
                if (closed || lm == null) {
                    inferenceStartedMs = 0L
                    return
                }
                lm.detectAsync(mpImage, tCaptureUs / 1_000L)
            }
        } catch (_: Throwable) {
            inferenceStartedMs = 0L
        }
    }

    private fun dispatch(result: FaceLandmarkerResult) {
        inferenceStartedMs = 0L
        val faces = result.faceLandmarks()
        if (faces.isEmpty()) {
            if (!closed) onFaceLost()
            return
        }
        val blends = result.faceBlendshapes()
            .takeIf { it.isPresent }
            ?.get()
            ?.firstOrNull()
            ?.associate { it.categoryName() to it.score() }
            ?: emptyMap()
        val m = result.facialTransformationMatrixes()
            .takeIf { it.isPresent }
            ?.get()
            ?.firstOrNull()
        var yawDeg = 0f
        var pitchDeg = 0f
        if (m != null && m.size >= 11) {
            val sy = kotlin.math.hypot(m[0].toDouble(), m[4].toDouble()).toFloat()
            if (sy > 1e-4f) {
                yawDeg = Math.toDegrees(kotlin.math.atan2(-m[8].toDouble(), sy.toDouble())).toFloat()
                pitchDeg = Math.toDegrees(kotlin.math.atan2(m[9].toDouble(), m[10].toDouble())).toFloat()
            }
        }
        if (closed) return
        onSignals(
            FaceSignals(
                blendshapes = blends,
                yawDeg = yawDeg,
                pitchDeg = pitchDeg,
                trackingQuality = 1f,
            )
        )
    }

    fun close() {
        closed = true
        synchronized(lock) {
            runCatching { landmarker?.close() }
            landmarker = null
        }
        inferenceStartedMs = 0L
    }

    companion object {
        const val MODEL_ASSET = "face_landmarker.task"
        const val EXPECTED_MODEL_SHA256 =
            "64184e229b263107bc2b804c6625db1341ff2bb731874b0bcc2fe6544e0bc9ff"
        private const val STALE_INFERENCE_MS = 1_000L

        fun verifyBundledModelSha256(context: Context): Boolean = runCatching {
            val digest = MessageDigest.getInstance("SHA-256")
            context.assets.open(MODEL_ASSET).use { stream ->
                val buf = ByteArray(16 * 1024)
                while (true) {
                    val read = stream.read(buf)
                    if (read <= 0) break
                    digest.update(buf, 0, read)
                }
            }
            val hex = digest.digest().joinToString("") { "%02x".format(it) }
            hex == EXPECTED_MODEL_SHA256
        }.getOrDefault(false)
    }
}

private fun Image.toUprightBitmap(rotationDegrees: Int, mirror: Boolean): Bitmap? {
    if (format != ImageFormat.YUV_420_888) return null
    val yPlane = planes[0]
    val uPlane = planes[1]
    val vPlane = planes[2]
    val nv21 = ByteArray(width * height * 3 / 2)
    var pos = 0

    val yBuf = yPlane.buffer
    val yRowStride = yPlane.rowStride
    if (yRowStride == width) {
        yBuf.get(nv21, 0, width * height)
        pos = width * height
    } else {
        val row = ByteArray(yRowStride)
        for (r in 0 until height) {
            yBuf.position(r * yRowStride)
            val len = minOf(yRowStride, yBuf.remaining())
            yBuf.get(row, 0, len)
            System.arraycopy(row, 0, nv21, pos, width)
            pos += width
        }
    }

    val uvRowStride = uPlane.rowStride
    val uvPixelStride = uPlane.pixelStride
    val uBuf = uPlane.buffer
    val vBuf = vPlane.buffer
    val uvHeight = height / 2
    val uvWidth = width / 2
    for (r in 0 until uvHeight) {
        for (c in 0 until uvWidth) {
            val idx = r * uvRowStride + c * uvPixelStride
            if (idx >= vBuf.limit() || idx >= uBuf.limit()) continue
            nv21[pos++] = vBuf.get(idx)
            nv21[pos++] = uBuf.get(idx)
        }
    }

    val out = ByteArrayOutputStream(width * height / 2)
    if (!YuvImage(nv21, ImageFormat.NV21, width, height, null)
            .compressToJpeg(Rect(0, 0, width, height), 85, out)
    ) {
        return null
    }
    val bytes = out.toByteArray()
    val source = BitmapFactory.decodeByteArray(bytes, 0, bytes.size) ?: return null
    if (rotationDegrees == 0 && !mirror) return source
    val matrix = Matrix().apply {
        postRotate(rotationDegrees.toFloat())
        if (mirror) postScale(-1f, 1f, source.width / 2f, source.height / 2f)
    }
    val rotated = try {
        Bitmap.createBitmap(source, 0, 0, source.width, source.height, matrix, true)
    } catch (_: Throwable) {
        source.recycle()
        return null
    }
    if (rotated !== source) source.recycle()
    return rotated
}
