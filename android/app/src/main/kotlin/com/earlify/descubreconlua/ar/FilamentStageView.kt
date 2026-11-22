package com.earlify.descubreconlua.ar

import android.content.Context
import android.view.Choreographer
import android.view.TextureView
import android.view.View
import com.google.android.filament.Colors
import com.google.android.filament.Engine
import com.google.android.filament.EntityManager
import com.google.android.filament.LightManager
import com.google.android.filament.Renderer
import com.google.android.filament.View as FilamentView
import com.google.android.filament.android.UiHelper
import com.google.android.filament.utils.ModelViewer
import com.google.android.filament.utils.Utils
import java.nio.ByteBuffer

/**
 * Capa 3D Filament transparente sobre TextureView (portada de Valeria, P10.4).
 */
class FilamentStageView(private val context: Context) {

    private var viewer: ModelViewer? = null
    private var choreographer: Choreographer? = null
    private var frameCallback: Choreographer.FrameCallback? = null
    private var lightEntity = 0

    @Volatile private var released = false
    private var attachedToWindow = false
    private var everAttached = false

    private var animationIndex = -1
    private var animationStartedNanos = 0L
    private var animationLoop = false

    fun createTextureView(modelAsset: String): TextureView {
        val tv = TextureView(context)
        attach(tv)
        loadModel(modelAsset)
        return tv
    }

    private fun attach(surface: TextureView) {
        runCatching {
            ensureNativeLibrary()
            val uiHelper = UiHelper(UiHelper.ContextErrorPolicy.DONT_CHECK).apply {
                isOpaque = false
            }
            val modelViewer = ModelViewer(surface, Engine.create(), uiHelper)
            viewer = modelViewer
            attachedToWindow = surface.isAttachedToWindow
            everAttached = attachedToWindow
            surface.addOnAttachStateChangeListener(object : View.OnAttachStateChangeListener {
                override fun onViewAttachedToWindow(v: View) {
                    attachedToWindow = true
                    everAttached = true
                }

                override fun onViewDetachedFromWindow(v: View) {
                    attachedToWindow = false
                    released = true
                    stopFrameLoop()
                    viewer = null
                    if (lightEntity != 0) {
                        runCatching { EntityManager.get().destroy(lightEntity) }
                        lightEntity = 0
                    }
                }
            })

            modelViewer.scene.skybox = null
            modelViewer.view.blendMode = FilamentView.BlendMode.TRANSLUCENT
            modelViewer.renderer.clearOptions = Renderer.ClearOptions().apply {
                clear = true
                clearColor = doubleArrayOf(0.0, 0.0, 0.0, 0.0)
            }

            lightEntity = EntityManager.get().create()
            val (r, g, b) = Colors.cct(6_500f)
            LightManager.Builder(LightManager.Type.DIRECTIONAL)
                .color(r, g, b)
                .intensity(110_000f)
                .direction(0.3f, -1f, -0.8f)
                .castShadows(false)
                .build(modelViewer.engine, lightEntity)
            modelViewer.scene.addEntity(lightEntity)
            startFrameLoop()
        }
    }

    fun loadModel(assetPath: String) {
        if (released || assetPath.isEmpty()) return
        val modelViewer = viewer ?: return
        runCatching {
            val bytes = context.assets.open(assetPath).use { it.readBytes() }
            val buffer = ByteBuffer.allocateDirect(bytes.size).apply {
                put(bytes)
                rewind()
            }
            modelViewer.loadModelGlb(buffer)
            modelViewer.transformToUnitCube()
            animationIndex = -1
        }
    }

    fun setProgress(progress: Float) {
        if (released) return
        val modelViewer = viewer ?: return
        val asset = modelViewer.asset ?: return
        runCatching {
            val tm = modelViewer.engine.transformManager
            val instance = tm.getInstance(asset.root)
            if (instance != 0) {
                val z = -progress.coerceIn(0f, 1f) * 1.4f
                tm.setTransform(
                    instance,
                    floatArrayOf(
                        1f, 0f, 0f, 0f,
                        0f, 1f, 0f, 0f,
                        0f, 0f, 1f, 0f,
                        0f, 0f, z, 1f,
                    ),
                )
            }
        }
    }

    fun playAnimation(name: String, loop: Boolean = false) {
        val animator = viewer?.animator ?: return
        for (i in 0 until animator.animationCount) {
            if (animator.getAnimationName(i) == name) {
                animationIndex = i
                animationStartedNanos = System.nanoTime()
                animationLoop = loop
                return
            }
        }
    }

    private fun startFrameLoop() {
        if (viewer == null) return
        val chore = Choreographer.getInstance()
        choreographer = chore
        val callback = object : Choreographer.FrameCallback {
            override fun doFrame(frameTimeNanos: Long) {
                if (released) return
                val modelViewer = viewer ?: return
                choreographer?.postFrameCallback(this)
                runCatching {
                    val animator = modelViewer.animator
                    if (animator != null && animationIndex >= 0) {
                        val elapsed = (frameTimeNanos - animationStartedNanos) / 1_000_000_000f
                        val duration = animator.getAnimationDuration(animationIndex)
                        val time = if (animationLoop && duration > 0f) elapsed % duration else elapsed
                        if (!animationLoop && duration > 0f && elapsed > duration) {
                            animationIndex = -1
                        } else {
                            animator.applyAnimation(animationIndex, time)
                            animator.updateBoneMatrices()
                        }
                    }
                    modelViewer.render(frameTimeNanos)
                }
            }
        }
        frameCallback = callback
        chore.postFrameCallback(callback)
    }

    private fun stopFrameLoop() {
        frameCallback?.let { cb -> runCatching { choreographer?.removeFrameCallback(cb) } }
        frameCallback = null
        choreographer = null
    }

    fun release() {
        if (released) return
        released = true
        stopFrameLoop()
        val modelViewer = viewer
        viewer = null
        if (modelViewer != null) {
            if (attachedToWindow) {
                runCatching {
                    if (lightEntity != 0) {
                        modelViewer.scene.removeEntity(lightEntity)
                        modelViewer.engine.destroyEntity(lightEntity)
                    }
                }
            } else if (!everAttached) {
                runCatching { modelViewer.destroy() }
            }
        }
        if (lightEntity != 0) {
            runCatching { EntityManager.get().destroy(lightEntity) }
            lightEntity = 0
        }
    }

    private companion object {
        @Volatile private var nativeLoaded = false
        fun ensureNativeLibrary() {
            if (nativeLoaded) return
            synchronized(this) {
                if (!nativeLoaded) {
                    Utils.init()
                    nativeLoaded = true
                }
            }
        }
    }
}
