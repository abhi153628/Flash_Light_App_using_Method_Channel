import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:permission_handler/permission_handler.dart';

class FlashlightController {
  static const platform = MethodChannel('samples.flutter.dev/flashlight');
  static Timer? _blinkTimer;

  static Future<bool> toggleFlashlight() async {
    try {
      final bool result = await platform.invokeMethod('toggleFlashlight');
      return result;
    } on PlatformException catch (e) {
      if (kDebugMode) {
        print("Failed to toggle flashlight: '${e.message}'.");
      }
      return false;
    }
  }

  static void startBlinking(Duration interval, Function(bool) onStateChange) {
    stopBlinking();
    _blinkTimer = Timer.periodic(interval, (timer) async {
      bool success = await toggleFlashlight();
      if (success) {
        onStateChange(timer.tick.isOdd);
      }
    });
  }

  static void stopBlinking() {
    _blinkTimer?.cancel();
    _blinkTimer = null;
  }
}

class FlashlightPage extends StatefulWidget {
  const FlashlightPage({super.key});

  @override
  _FlashlightPageState createState() => _FlashlightPageState();
}

class _FlashlightPageState extends State<FlashlightPage> with TickerProviderStateMixin {
  bool _isFlashlightOn = false;
  bool _isBlinking = false;
  double _blinkSpeed = 500;
  bool _hasPermission = false;
  
  // Combined animation controller for both button and torch animations
  late final AnimationController _mainAnimationController;
  late final Animation<double> _buttonSlideAnimation;
  late final Animation<double> _torchGlowAnimation;
  late final Animation<double> _buttonScaleAnimation;

  @override
  void initState() {
    super.initState();
    _checkPermissions();
    
    // Initialize single animation controller for all animations
    _mainAnimationController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );

    // Button slide animation
    _buttonSlideAnimation = Tween<double>(
      begin: 0,
      end: -60, // Slides up when turned on
    ).animate(CurvedAnimation(
      parent: _mainAnimationController,
      curve: Curves.easeInOut,
    ));

    // Torch glow animation
    _torchGlowAnimation = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(CurvedAnimation(
      parent: _mainAnimationController,
      curve: Curves.easeIn,
    ));

    // Button scale animation
    _buttonScaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.9,
    ).animate(CurvedAnimation(
      parent: _mainAnimationController,
      curve: Curves.easeInOut,
    ));
  }

  Future<void> _checkPermissions() async {
    if (await Permission.camera.request().isGranted) {
      setState(() {
        _hasPermission = true;
      });
    }
  }

  @override
  void dispose() {
    FlashlightController.stopBlinking();
    _mainAnimationController.dispose();
    super.dispose();
  }

  void _toggleFlashlight() async {
    if (_hasPermission) {
      bool success = await FlashlightController.toggleFlashlight();
      if (success) {
        setState(() {
          _isFlashlightOn = !_isFlashlightOn;
          _isBlinking = false;
        });
        
        if (_isFlashlightOn) {
          _mainAnimationController.forward();
        } else {
          _mainAnimationController.reverse();
        }
        
        FlashlightController.stopBlinking();
      }
    }
  }

  void _toggleBlinking() {
    setState(() {
      _isBlinking = !_isBlinking;
      if (_isBlinking) {
        FlashlightController.startBlinking(
          Duration(milliseconds: _blinkSpeed.round()),
          (isOn) {
            setState(() {
              _isFlashlightOn = isOn;
              if (isOn) {
                _mainAnimationController.forward();
              } else {
                _mainAnimationController.reverse();
              }
            });
          },
        );
      } else {
        FlashlightController.stopBlinking();
        _isFlashlightOn = false;
        _mainAnimationController.reverse();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text('Turn On Flashlight', style: GoogleFonts.aBeeZee(color: Color(0xFFe3e39c))),
        backgroundColor: Colors.black,
        centerTitle: true,
      ),
      body: AnimatedBuilder(
        animation: _mainAnimationController,
        builder: (context, child) {
          return Container(
            width: double.infinity,
            height: double.infinity,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.black,
                  Color.lerp(Colors.black, Color(0xFFe3e39c),
                      _torchGlowAnimation.value * 0.3)!,
                ],
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Torch beam effect
                AnimatedContainer(
                  duration: Duration(milliseconds: 200),
                  width: 120,
                  height: _isFlashlightOn ? 200 : 150,
                  decoration: BoxDecoration(
                    color: Color(0xFFe3e39c).withOpacity(_torchGlowAnimation.value * 0.3),
                    borderRadius: BorderRadius.circular(60),
                    boxShadow: _isFlashlightOn
                        ? [
                            BoxShadow(
                              color: Color(0xFFe3e39c)
                                  .withOpacity(_torchGlowAnimation.value * 0.5),
                              blurRadius: 30,
                              spreadRadius: 10,
                            )
                          ]
                        : [],
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Power button
                      Transform.translate(
                        offset: Offset(0, _buttonSlideAnimation.value),
                        child: Transform.scale(
                          scale: _buttonScaleAnimation.value,
                          child: GestureDetector(
                            onTap: _toggleFlashlight,
                            child: Container(
                              width: 80,
                              height: 80,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: _isFlashlightOn
                                    ? Color(0xFFe3e39c)
                                    : Colors.grey[800],
                                boxShadow: [
                                  BoxShadow(
                                    color: _isFlashlightOn
                                        ? Color(0xFFe3e39c).withOpacity(0.5)
                                        : Colors.black26,
                                    blurRadius: 15,
                                    spreadRadius: 5,
                                  ),
                                ],
                              ),
                              child: Icon(
                                Icons.power_settings_new,
                                color: _isFlashlightOn ? Colors.black : Colors.white,
                                size: 40,
                              ),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: 20),
                      Text(
                        _isFlashlightOn ? "ON" : "OFF",
                        style: GoogleFonts.roboto(
                          color: _isFlashlightOn ? Colors.black : Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 40),
                // Blink control
                ElevatedButton(
                  onPressed: _toggleBlinking,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _isBlinking ? Colors.red : Color(0xFFe3e39c),
                    padding: EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25),
                    ),
                  ),
                  child: Text(
                    _isBlinking ? 'Stop Blinking' : 'Start Blinking',
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                if (_isBlinking) ...[
                  SizedBox(height: 20),
                  Slider(
                    value: _blinkSpeed,
                    min: 100,
                    max: 1000,
                    activeColor: Color(0xFFe3e39c),
                    inactiveColor: Colors.grey[800],
                    onChanged: (value) {
                      setState(() {
                        _blinkSpeed = value;
                        if (_isBlinking) {
                          _toggleBlinking();
                          _toggleBlinking();
                        }
                      });
                    },
                  ),
                  Text(
                    'Blink Speed: ${_blinkSpeed.round()}ms',
                    style: TextStyle(color: Colors.white),
                  ),
                ],
              ],
            ),
          );
        },
      ),
    );
  }
}