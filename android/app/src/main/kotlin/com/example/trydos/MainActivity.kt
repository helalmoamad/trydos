package com.example.trydos

import android.content.Context
import android.media.AudioDeviceInfo
import android.media.AudioManager
import android.os.Build
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity: FlutterActivity() {
    private val CHANNEL = "com.trydos.audio/settings"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        flutterEngine.plugins.add(MemoryInfoPlugin())

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            if (call.method == "setCallAudioMode") {
                val enable = call.arguments as? Boolean ?: false
                setCallAudioMode(enable)
                result.success(null)
            } else {
                result.notImplemented()
            }
        }
    }

    private fun setCallAudioMode(enable: Boolean) {
        val am = getSystemService(Context.AUDIO_SERVICE) as AudioManager
        if (enable) {
            // Earpiece Mode
            am.mode = AudioManager.MODE_IN_COMMUNICATION
            am.isSpeakerphoneOn = false
            
            // For Android 12 (API 31) and above
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
                val devices = am.availableCommunicationDevices
                val earpiece = devices.find { it.type == AudioDeviceInfo.TYPE_BUILTIN_EARPIECE }
                if (earpiece != null) {
                    am.setCommunicationDevice(earpiece)
                }
            }
        } else {
            // Speaker Mode / Normal
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
                am.clearCommunicationDevice()
            }
            am.mode = AudioManager.MODE_NORMAL
            am.isSpeakerphoneOn = true
        }
    }
}
