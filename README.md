# Flutter Flashlight Controller App

A modern, feature-rich flashlight controller application built with Flutter that demonstrates native device integration using Method Channels. The app offers an intuitive user interface with gesture controls and customizable blinking patterns.

## 📱 Features

- **Toggle Flashlight**: Simple on/off functionality with gesture controls
- **Gesture Control**: 
  - Swipe up to turn on
  - Swipe down to turn off
  - Smooth animation feedback
- **Blinking Mode**:
  - Customizable blinking speed
  - Interactive speed control slider
  - Start/Stop functionality
- **Modern UI**:
  - Material Design 3
  - Animated transitions
  - Visual feedback
  - Compass heading display
- **Permission Handling**: Runtime permission management for camera access

## 🛠️ Technologies Used

- **Flutter**: UI framework for cross-platform development
- **Dart**: Programming language for application logic
- **Method Channel**: Bridge between Flutter and native Android code
- **Kotlin**: Native Android implementation
- **Camera2 API**: Android's camera hardware access
- **Google Fonts**: Custom typography
- **Permission Handler**: Runtime permission management
- **Material Design 3**: UI design system

## 📋 Prerequisites

- Flutter SDK (version 3.0 or higher)
- Android Studio / VS Code
- Android SDK
- Kotlin support
- A physical device with flashlight capability (emulators don't support flashlight)

## 💻 Installation

1. Clone the repository:
```bash
git clone https://github.com/yourusername/flutter-flashlight-controller.git
```

2. Navigate to project directory:
```bash
cd flutter-flashlight-controller
```

3. Install dependencies:
```bash
flutter pub get
```

4. Run the app:
```bash
flutter run
```

## 🔌 Method Channel Implementation

This app demonstrates Flutter-Native communication using Method Channels. Here's how it works:

### Flutter Side (Dart)
```dart
static const platform = MethodChannel('samples.flutter.dev/flashlight');

// Method to toggle flashlight
static Future<bool> toggleFlashlight() async {
  try {
    final bool result = await platform.invokeMethod('toggleFlashlight');
    return result;
  } on PlatformException catch (e) {
    print("Failed to toggle flashlight: '${e.message}'.");
    return false;
  }
}
```

### Native Side (Kotlin)
```kotlin
class MainActivity : FlutterActivity() {
    private val CHANNEL = "samples.flutter.dev/flashlight"
    
    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL)
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    "toggleFlashlight" -> {
                        // Handle flashlight toggle
                    }
                    else -> result.notImplemented()
                }
            }
    }
}
```

## 📱 Screenshots

[Place your screenshots here]

## 🔒 Permissions

The app requires the following permissions:
- Camera access (for flashlight control)
```xml
<uses-permission android:name="android.permission.CAMERA" />
<uses-feature android:name="android.hardware.camera" />
<uses-feature android:name="android.hardware.camera.flash" />
```

## 🤝 Contributing

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request



## 👨‍💻 Author

Your Name - https://github.com/abhi153628

## 🙏 Acknowledgments

- Flutter team for the amazing framework
- Material Design team for the design system
- The open-source community for various packages used

## 📞 Contact - 8590646692

Your Name - [Abhishek R - abhishekramesh2424@gmail.com]

Project Link: [https://github.com/yourusername/flutter-flashlight-controller](https://github.com/yourusername/flutter-flashlight-controller)