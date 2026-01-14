package com.example.english_learning_app

import android.media.MediaPlayer
import android.os.Handler
import android.os.Looper
import androidx.annotation.NonNull
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

/**
 * MainActivity - 处理音频播放的原生Android代码
 * 
 * 通过MethodChannel与Flutter通信：
 * - play: 播放指定路径的音频文件
 * - stop: 停止当前播放
 */
class MainActivity: FlutterActivity() {
    // MethodChannel名称（必须与Flutter代码一致）
    private val CHANNEL_NAME = "audio_player"
    
    private var methodChannel: MethodChannel? = null
    private var mediaPlayer: MediaPlayer? = null
    private val handler = Handler(Looper.getMainLooper())
    
    override fun configureFlutterEngine(@NonNull flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        
        // 创建MethodChannel
        methodChannel = MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            CHANNEL_NAME
        )
        
        // 设置方法处理器
        methodChannel?.setMethodCallHandler { call, result ->
            when (call.method) {
                "play" -> {
                    val path = call.argument<String>("path")
                    if (path != null) {
                        playAudio(path, result)
                    } else {
                        result.error("INVALID_ARGUMENT", "Path is required", null)
                    }
                }
                "stop" -> {
                    stopAudio()
                    result.success(true)
                }
                else -> {
                    result.notImplemented()
                }
            }
        }
    }
    
    /**
     * 播放音频文件
     * 
     * @param path 音频文件路径
     * @param result MethodChannel结果回调
     */
    private fun playAudio(path: String, result: MethodChannel.Result) {
        try {
            // 如果已有播放器，先释放
            releaseMediaPlayer()
            
            // 创建新的MediaPlayer
            mediaPlayer = MediaPlayer().apply {
                setDataSource(path)
                setOnPreparedListener { mp ->
                    // 准备完成后开始播放
                    mp.start()
                    result.success(true)
                }
                setOnCompletionListener {
                    // 播放完成回调
                    handler.post {
                        methodChannel?.invokeMethod("onCompletion", null)
                    }
                    releaseMediaPlayer()
                }
                setOnErrorListener { _, what, extra ->
                    // 播放错误回调
                    handler.post {
                        methodChannel?.invokeMethod("onError", mapOf(
                            "what" to what,
                            "extra" to extra,
                            "message" to "Audio playback error: what=$what, extra=$extra"
                        ))
                    }
                    releaseMediaPlayer()
                    true
                }
                // 异步准备
                prepareAsync()
            }
            
        } catch (e: Exception) {
            // 发送错误信息到Flutter
            handler.post {
                methodChannel?.invokeMethod("onError", mapOf(
                    "message" to "Failed to play audio: ${e.message}"
                ))
            }
            result.error("PLAY_ERROR", "Failed to play audio: ${e.message}", null)
        }
    }
    
    /**
     * 停止音频播放
     */
    private fun stopAudio() {
        try {
            mediaPlayer?.apply {
                if (isPlaying) {
                    stop()
                }
                release()
            }
        } catch (e: Exception) {
            e.printStackTrace()
        } finally {
            mediaPlayer = null
        }
    }
    
    /**
     * 释放MediaPlayer资源
     */
    private fun releaseMediaPlayer() {
        try {
            mediaPlayer?.apply {
                if (isPlaying) {
                    stop()
                }
                release()
            }
        } catch (e: Exception) {
            e.printStackTrace()
        } finally {
            mediaPlayer = null
        }
    }
    
    override fun onDestroy() {
        super.onDestroy()
        // Activity销毁时释放资源
        releaseMediaPlayer()
    }
}
