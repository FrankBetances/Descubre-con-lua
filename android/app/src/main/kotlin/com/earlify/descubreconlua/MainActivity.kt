package com.earlify.descubreconlua

import android.content.res.AssetFileDescriptor
import android.media.AudioAttributes
import android.media.MediaPlayer
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

/**
 * Hosts the offline audio bridge.
 *
 * Playback goes through the platform's own MediaPlayer reading a bundled asset
 * file descriptor. No third-party audio library is added, so the release APK
 * keeps zero dependencies that could open a network connection.
 */
class MainActivity : FlutterActivity() {

    private var player: MediaPlayer? = null
    private var channel: MethodChannel? = null

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        val methodChannel = MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            CHANNEL,
        )
        channel = methodChannel

        methodChannel.setMethodCallHandler { call, result ->
            when (call.method) {
                "play" -> {
                    val asset = call.argument<String>("asset")
                    if (asset.isNullOrBlank()) {
                        result.error("EMPTY_ASSET", "Asset path cannot be empty", null)
                    } else {
                        play(asset, result)
                    }
                }
                "pause" -> {
                    runCatching { player?.takeIf { it.isPlaying }?.pause() }
                    result.success(null)
                }
                "stop" -> {
                    releasePlayer()
                    result.success(null)
                }
                "release" -> {
                    releasePlayer()
                    result.success(null)
                }
                else -> result.notImplemented()
            }
        }
    }

    private fun play(assetPath: String, result: MethodChannel.Result) {
        // Resuming the same recording must not restart it from the beginning:
        // a teacher pausing mid-verse expects the pulse to continue.
        val current = player
        if (current != null && currentAsset == assetPath) {
            runCatching { current.start() }
                .onSuccess { result.success(null) }
                .onFailure { result.error("PLAY_FAILED", it.message, null) }
            return
        }

        releasePlayer()

        val lookupKey = flutterLoader().getLookupKeyForAsset(assetPath)

        var descriptor: AssetFileDescriptor? = null
        try {
            descriptor = assets.openFd(lookupKey)
            val mediaPlayer = MediaPlayer().apply {
                setAudioAttributes(
                    AudioAttributes.Builder()
                        .setUsage(AudioAttributes.USAGE_MEDIA)
                        .setContentType(AudioAttributes.CONTENT_TYPE_SPEECH)
                        .build(),
                )
                setDataSource(
                    descriptor.fileDescriptor,
                    descriptor.startOffset,
                    descriptor.length,
                )
                setOnCompletionListener { channel?.invokeMethod("onCompleted", null) }
                prepare()
                start()
            }
            player = mediaPlayer
            currentAsset = assetPath
            result.success(null)
        } catch (e: Exception) {
            releasePlayer()
            // A recording that is not in the package is a build defect, not a
            // silent no-op: the Dart side turns this into a visible message.
            result.error("ASSET_UNAVAILABLE", e.message ?: "Cannot play $assetPath", null)
        } finally {
            runCatching { descriptor?.close() }
        }
    }

    private fun releasePlayer() {
        runCatching {
            player?.apply {
                if (isPlaying) stop()
                release()
            }
        }
        player = null
        currentAsset = null
    }

    private fun flutterLoader() =
        io.flutter.FlutterInjector.instance().flutterLoader()

    override fun onDestroy() {
        releasePlayer()
        channel?.setMethodCallHandler(null)
        channel = null
        super.onDestroy()
    }

    private var currentAsset: String? = null

    private companion object {
        const val CHANNEL = "com.earlify.descubreconlua/audio"
    }
}
