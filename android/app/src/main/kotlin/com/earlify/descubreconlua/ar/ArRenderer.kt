package com.earlify.descubreconlua.ar

import android.opengl.GLES20
import android.opengl.GLSurfaceView
import com.google.ar.core.Frame
import javax.microedition.khronos.egl.EGLConfig
import javax.microedition.khronos.opengles.GL10

/**
 * Bucle único en hilo GL para ARCore + render de fondo y escena.
 * Portado de Valeria (P10.4).
 */
class ArRenderer(
    private val session: ArCoreSession,
    private val onFrame: (Frame) -> Unit,
    private val onGlError: (String) -> Unit,
) : GLSurfaceView.Renderer {

    private val background = CameraBackgroundRenderer()
    private var textureBound = false
    private var surfaceWidth = 0
    private var surfaceHeight = 0

    @Volatile private var pendingRotation = 0
    @Volatile private var viewportChanged = false
    private var displayRotation = 0

    override fun onSurfaceCreated(gl: GL10?, config: EGLConfig?) {
        GLES20.glClearColor(0f, 0f, 0f, 1f)
        try {
            background.createOnGlThread()
            textureBound = false
        } catch (e: Throwable) {
            onGlError(e.message ?: e.javaClass.simpleName)
        }
    }

    override fun onSurfaceChanged(gl: GL10?, width: Int, height: Int) {
        GLES20.glViewport(0, 0, width, height)
        surfaceWidth = width
        surfaceHeight = height
        viewportChanged = true
    }

    fun setDisplayRotation(rotation: Int) {
        pendingRotation = rotation
        viewportChanged = true
    }

    override fun onDrawFrame(gl: GL10?) {
        GLES20.glClear(GLES20.GL_COLOR_BUFFER_BIT or GLES20.GL_DEPTH_BUFFER_BIT)
        val s = session.session ?: return
        if (!textureBound && background.textureId > 0) {
            s.setCameraTextureName(background.textureId)
            textureBound = true
        }
        if (viewportChanged && surfaceWidth > 0 && surfaceHeight > 0) {
            displayRotation = pendingRotation
            s.setDisplayGeometry(displayRotation, surfaceWidth, surfaceHeight)
            viewportChanged = false
        }
        val frame = session.update() ?: return
        background.draw(frame)
        onFrame(frame)
    }
}
