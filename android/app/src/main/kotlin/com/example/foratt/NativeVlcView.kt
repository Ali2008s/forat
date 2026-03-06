package com.example.foratt

import android.content.Context
import android.net.Uri
import android.os.Handler
import android.os.Looper
import android.view.View
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.platform.PlatformView
import org.videolan.libvlc.LibVLC
import org.videolan.libvlc.Media
import org.videolan.libvlc.MediaPlayer
import org.videolan.libvlc.util.VLCVideoLayout

class NativeVlcView(
    context: Context,
    messenger: BinaryMessenger,
    id: Int,
    creationParams: Map<String?, Any?>?
) : PlatformView, MethodChannel.MethodCallHandler {

    private val videoLayout: VLCVideoLayout = VLCVideoLayout(context)
    private var libVLC: LibVLC? = null
    private var mediaPlayer: MediaPlayer? = null
    private val methodChannel: MethodChannel
    private val handler = Handler(Looper.getMainLooper())

    private var url: String? = creationParams?.get("url") as String?
    private var isLive: Boolean = (creationParams?.get("isLive") as Boolean?) ?: false

    init {
        methodChannel = MethodChannel(messenger, "native_vlc_player_$id")
        methodChannel.setMethodCallHandler(this)
        
        setupVlc(context)
    }

    private fun setupVlc(context: Context) {
        val args = ArrayList<String>()
        args.add("--network-caching=3000")
        args.add("--drop-late-frames")
        args.add("--skip-frames")
        args.add("--avcodec-hw=any") // Try hw, fallback to sw
        
        libVLC = LibVLC(context, args)
        mediaPlayer = MediaPlayer(libVLC)
        mediaPlayer?.attachViews(videoLayout, null, false, false)

        mediaPlayer?.setEventListener { event: MediaPlayer.Event ->
            when (event.type) {
                MediaPlayer.Event.Playing -> {
                    handler.post { methodChannel.invokeMethod("onStateChanged", "playing") }
                }
                MediaPlayer.Event.Paused -> {
                    handler.post { methodChannel.invokeMethod("onStateChanged", "paused") }
                }
                MediaPlayer.Event.EndReached -> {
                    handler.post { methodChannel.invokeMethod("onStateChanged", "ended") }
                }
                MediaPlayer.Event.EncounteredError -> {
                    handler.post { methodChannel.invokeMethod("onError", "Playback Error") }
                }
                MediaPlayer.Event.Buffering -> {
                    handler.post { methodChannel.invokeMethod("onStateChanged", "buffering") }
                }
            }
        }

        url?.let { loadMedia(it) }
    }

    private fun loadMedia(url: String) {
        try {
            val media = Media(libVLC, Uri.parse(url))
            media.setHWDecoderEnabled(true, false)
            mediaPlayer?.media = media
            media?.release()
            mediaPlayer?.play()
        } catch (e: Exception) {
            e.printStackTrace()
        }
    }

    override fun getView(): View {
        return videoLayout
    }

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        when (call.method) {
            "play" -> {
                mediaPlayer?.play()
                result.success(null)
            }
            "pause" -> {
                mediaPlayer?.pause()
                result.success(null)
            }
            "seekTo" -> {
                val position = call.argument<Int>("position")?.toLong() ?: 0L
                mediaPlayer?.time = position
                result.success(null)
            }
            "load" -> {
                val newUrl = call.argument<String>("url")
                if (newUrl != null) {
                    this.url = newUrl
                    loadMedia(newUrl)
                }
                result.success(null)
            }
            "getPosition" -> {
                val pos = mediaPlayer?.time ?: 0L
                result.success(pos)
            }
            "getDuration" -> {
                val dur = mediaPlayer?.length ?: 0L
                result.success(dur)
            }
            "setAspectRatio" -> {
                val aspect = call.argument<String>("aspectRatio") // e.g. "16:9", "4:3", "FILL"
                mediaPlayer?.aspectRatio = if (aspect == "FILL") null else aspect
                mediaPlayer?.scale = 0f
                result.success(null)
            }
            else -> result.notImplemented()
        }
    }

    override fun dispose() {
        methodChannel.setMethodCallHandler(null)
        mediaPlayer?.stop()
        mediaPlayer?.detachViews()
        mediaPlayer?.release()
        libVLC?.release()
    }
}
