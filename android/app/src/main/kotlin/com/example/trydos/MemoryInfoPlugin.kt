package com.example.trydos

import android.app.ActivityManager
import android.content.Context
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result

class MemoryInfoPlugin: FlutterPlugin, MethodCallHandler {
  private lateinit var channel: MethodChannel
  private lateinit var context: Context

  override fun onAttachedToEngine(flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
    channel = MethodChannel(flutterPluginBinding.binaryMessenger, "memory_info")
    channel.setMethodCallHandler(this)
    context = flutterPluginBinding.applicationContext
  }

  override fun onMethodCall(call: MethodCall, result: Result) {
    when (call.method) {
      "getTotalMemory" -> {
        try {
          val memoryInfo = getMemoryInfo()
          result.success(memoryInfo)
        } catch (e: Exception) {
          result.error("MEMORY_ERROR", "Failed to get memory info: ${e.message}", null)
        }
      }
      else -> {
        result.notImplemented()
      }
    }
  }

  private fun getMemoryInfo(): Map<String, Any> {
    val activityManager = context.getSystemService(Context.ACTIVITY_SERVICE) as ActivityManager
    val memoryInfo = ActivityManager.MemoryInfo()
    activityManager.getMemoryInfo(memoryInfo)

    val totalMemoryMB = try {
      memoryInfo.totalMem / (1024 * 1024)
    } catch (e: Exception) {
      val runtime = Runtime.getRuntime()
      val maxMemory = runtime.maxMemory()
      (maxMemory / (1024 * 1024)) * 4
    }

    return mapOf(
      "totalMemoryMB" to totalMemoryMB,
      "availableMemoryMB" to (memoryInfo.availMem / (1024 * 1024)),
      "isLowMemory" to memoryInfo.lowMemory
    )
  }

  override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
    channel.setMethodCallHandler(null)
  }
} 