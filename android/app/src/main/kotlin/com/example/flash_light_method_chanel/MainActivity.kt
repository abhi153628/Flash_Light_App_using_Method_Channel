/**
 * Android implementation of the Flashlight functionality for Flutter.
 * This class manages the native Android camera flash/torch functionality and communicates
 * with the Flutter application through a MethodChannel.
 *
 * Package: com.example.flash_light_method_chanel
 */

package com.example.flash_light_method_chanel

import android.content.Context
import android.hardware.camera2.CameraManager
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

/**
 * MainActivity extends FlutterActivity to handle native Android functionality
 * for controlling the device's flashlight/torch.
 *
 * Features:
 * - Initializes camera service
 * - Manages flashlight state
 * - Handles Flutter-Android communication
 * - Ensures proper cleanup on destroy
 */
class MainActivity : FlutterActivity() {
    // Constants and Properties
    
    /**
     * Method channel identifier for Flutter-Android communication
     * Matches the channel name used in the Flutter code
     */
    private val CHANNEL = "samples.flutter.dev/flashlight"
    
    /**
     * Tracks the current state of the flashlight
     * true = on, false = off
     */
    private var isFlashlightOn = false
    
    /**
     * Camera manager instance for accessing device camera features
     * Initialized in configureFlutterEngine
     */
    private lateinit var cameraManager: CameraManager
    
    /**
     * Stores the ID of the camera with flash capability
     * Can be null if no flash is available
     */
    private var cameraId: String? = null

    /**
     * Configures the Flutter engine and sets up native functionality
     * Called when the Flutter activity is created
     *
     * @param flutterEngine The Flutter engine instance
     */
    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        
        // Initialize camera system service
        try {
            // Get camera service and find camera with flash
            cameraManager = getSystemService(Context.CAMERA_SERVICE) as CameraManager
            
            // Find the first camera that has a flash available
            cameraId = cameraManager.cameraIdList.firstOrNull { id ->
                val characteristics = cameraManager.getCameraCharacteristics(id)
                characteristics.get(android.hardware.camera2.CameraCharacteristics.FLASH_INFO_AVAILABLE) == true
            }
        } catch (e: Exception) {
            println("Failed to initialize camera: ${e.message}")
        }

        // Set up method channel handler
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                // Handle toggleFlashlight method calls from Flutter
                "toggleFlashlight" -> {
                    // Check if flash is available
                    if (cameraId == null) {
                        result.error(
                            "FLASHLIGHT_ERROR",
                            "No flash available on this device",
                            null
                        )
                        return@setMethodCallHandler
                    }
                    
                    // Attempt to toggle flashlight state
                    try {
                        isFlashlightOn = !isFlashlightOn
                        cameraManager.setTorchMode(cameraId!!, isFlashlightOn)
                        result.success(true)
                    } catch (e: Exception) {
                        result.error(
                            "FLASHLIGHT_ERROR",
                            "Failed to toggle flashlight",
                            e.toString()
                        )
                    }
                }
                // Handle unknown method calls
                else -> result.notImplemented()
            }
        }
    }

    /**
     * Cleanup method called when the activity is being destroyed
     * Ensures flashlight is turned off when the app is closed
     */
    override fun onDestroy() {
        super.onDestroy()
        // Turn off flashlight if it's on
        if (isFlashlightOn) {
            try {
                cameraId?.let {
                    cameraManager.setTorchMode(it, false)
                }
            } catch (e: Exception) {
                println("Failed to turn off flashlight on destroy: ${e.message}")
            }
        }
    }
}