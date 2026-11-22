package com.earlify.descubreconlua.ar

import android.app.Activity
import android.media.Image
import android.util.Log
import com.google.ar.core.ArCoreApk
import com.google.ar.core.AugmentedFace
import com.google.ar.core.CameraConfig
import com.google.ar.core.CameraConfigFilter
import com.google.ar.core.Config
import com.google.ar.core.Frame
import com.google.ar.core.Session
import com.google.ar.core.TrackingState
import com.google.ar.core.exceptions.CameraNotAvailableException
import com.google.ar.core.exceptions.UnavailableApkTooOldException
import com.google.ar.core.exceptions.UnavailableArcoreNotInstalledException
import com.google.ar.core.exceptions.UnavailableDeviceNotCompatibleException
import com.google.ar.core.exceptions.UnavailableSdkTooOldException
import com.google.ar.core.exceptions.UnavailableUserDeclinedInstallationException

/**
 * Sesión local de ARCore (portada de Valeria, P10.4).
 *
 * Solo abre la cámara cuando la persona adulta inicia una escena de RA,
 * entrega los frames exclusivamente a memoria volátil / GPU, y ofrece motivos
 * claros ante dispositivos sin ARCore para caer sin fallos al modo lámina.
 */
class ArCoreSession(private val activity: Activity, private val rear: Boolean = false) {

    enum class Unavailable {
        DEVICE_NOT_SUPPORTED,
        INSTALL_DECLINED,
        APK_TOO_OLD,
        NO_FRONT_CAMERA,
        CAMERA_BUSY,
        INSTALL_PENDING,
        UNKNOWN,
    }

    var session: Session? = null
        private set

    var unavailable: Unavailable? = null
        private set

    var detail: String? = null
        private set

    private var installRequested = false

    fun ensureCreated(): Boolean {
        if (session != null) return true
        unavailable = null
        detail = null
        return try {
            val availability = ArCoreApk.getInstance().checkAvailability(activity)
            if (availability.isTransient) {
                unavailable = Unavailable.INSTALL_PENDING
                return false
            }
            if (!availability.isSupported) {
                unavailable = Unavailable.DEVICE_NOT_SUPPORTED
                return false
            }
            val installStatus = ArCoreApk.getInstance().requestInstall(activity, !installRequested)
            if (installStatus == ArCoreApk.InstallStatus.INSTALL_REQUESTED) {
                installRequested = true
                unavailable = Unavailable.INSTALL_PENDING
                return false
            }

            val created = Session(activity)
            val filter = CameraConfigFilter(created).apply {
                facingDirection = if (rear) {
                    CameraConfig.FacingDirection.BACK
                } else {
                    CameraConfig.FacingDirection.FRONT
                }
            }
            val configs = created.getSupportedCameraConfigs(filter)
            if (configs.isEmpty()) {
                created.close()
                unavailable = Unavailable.NO_FRONT_CAMERA
                return false
            }
            created.cameraConfig = configs.first()
            val config = Config(created).apply {
                if (rear) {
                    planeFindingMode = Config.PlaneFindingMode.HORIZONTAL
                    lightEstimationMode = Config.LightEstimationMode.AMBIENT_INTENSITY
                } else {
                    augmentedFaceMode = Config.AugmentedFaceMode.MESH3D
                    planeFindingMode = Config.PlaneFindingMode.DISABLED
                }
                updateMode = Config.UpdateMode.LATEST_CAMERA_IMAGE
            }
            created.configure(config)
            session = created
            true
        } catch (_: UnavailableArcoreNotInstalledException) {
            unavailable = Unavailable.INSTALL_PENDING
            false
        } catch (_: UnavailableUserDeclinedInstallationException) {
            unavailable = Unavailable.INSTALL_DECLINED
            false
        } catch (_: UnavailableApkTooOldException) {
            unavailable = Unavailable.APK_TOO_OLD
            false
        } catch (_: UnavailableSdkTooOldException) {
            unavailable = Unavailable.APK_TOO_OLD
            false
        } catch (_: UnavailableDeviceNotCompatibleException) {
            unavailable = Unavailable.DEVICE_NOT_SUPPORTED
            false
        } catch (t: Throwable) {
            Log.w(TAG, "ARCore session error", t)
            unavailable = Unavailable.UNKNOWN
            detail = t.javaClass.simpleName
            false
        }
    }

    fun resume(): Boolean {
        val s = session ?: return false
        return try {
            s.resume()
            true
        } catch (_: CameraNotAvailableException) {
            unavailable = Unavailable.CAMERA_BUSY
            false
        } catch (t: Throwable) {
            unavailable = Unavailable.UNKNOWN
            detail = t.javaClass.simpleName
            false
        }
    }

    fun pause() {
        runCatching { session?.pause() }
    }

    fun close() {
        runCatching { session?.close() }
        session = null
    }

    fun update(): Frame? = runCatching { session?.update() }.getOrNull()

    fun trackedFace(): AugmentedFace? = session?.getAllTrackables(AugmentedFace::class.java)
        ?.firstOrNull { it.trackingState == TrackingState.TRACKING }

    fun acquireImage(frame: Frame): Image? = runCatching { frame.acquireCameraImage() }.getOrNull()

    companion object {
        private const val TAG = "LuaArCoreSession"

        fun isArCoreSupported(activity: Activity): Boolean = runCatching {
            val av = ArCoreApk.getInstance().checkAvailability(activity)
            av.isSupported
        }.getOrDefault(false)
    }
}
