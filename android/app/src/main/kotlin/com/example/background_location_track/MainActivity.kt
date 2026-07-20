package com.example.background_location_track

import android.content.Context
import android.os.BatteryManager
import android.os.Build
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.embedding.android.FlutterActivity
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    private val batteryChannel = "background_location_tracker/battery"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            batteryChannel
        ).setMethodCallHandler { call, result ->
            if (call.method == "getBatteryPercentage") {
                result.success(getBatteryPercentage())
            } else {
                result.notImplemented()
            }
        }
    }

    private fun getBatteryPercentage(): Int {
        val batteryManager = getSystemService(Context.BATTERY_SERVICE) as BatteryManager
        return if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.LOLLIPOP) {
            batteryManager.getIntProperty(BatteryManager.BATTERY_PROPERTY_CAPACITY)
        } else {
            -1
        }
    }
}
