import 'dart:math' as math;

import 'package:flutter/material.dart';

class HorizontalBlinkSpeedSelector extends StatefulWidget {
  final double initialSpeed;
  final ValueChanged<double> onSpeedChanged;

  const HorizontalBlinkSpeedSelector({
    Key? key, 
    required this.initialSpeed, 
    required this.onSpeedChanged,
  }) : super(key: key);

  @override
  _HorizontalBlinkSpeedSelectorState createState() => _HorizontalBlinkSpeedSelectorState();
}

class _HorizontalBlinkSpeedSelectorState extends State<HorizontalBlinkSpeedSelector> {
  late double _currentSpeed;

  @override
  void initState() {
    super.initState();
    _currentSpeed = widget.initialSpeed;
  }

  // Convert speed to a percentage (lower ms = higher percentage)
  double _speedToPercentage(double speed) {
    // Invert and normalize the speed (100-1000 ms range)
    return 1 - ((speed - 100) / 900);
  }

  // Convert percentage back to speed
  double _percentageToSpeed(double percentage) {
    // Ensure the percentage is between 0 and 1
    final clampedPercentage = math.max(0, math.min(1, percentage));
    // Convert back to speed range (100-1000 ms)
    return 1000 - (clampedPercentage * 900);
  }

  @override
  Widget build(BuildContext context) {
    final percentage = _speedToPercentage(_currentSpeed);

    return GestureDetector(
      onHorizontalDragUpdate: (details) {
        // Calculate new percentage based on horizontal drag
        final RenderBox box = context.findRenderObject() as RenderBox;
        final localPosition = box.globalToLocal(details.globalPosition);
        final newPercentage = localPosition.dx / box.size.width;
        
        final newSpeed = _percentageToSpeed(newPercentage);
        setState(() {
          _currentSpeed = newSpeed.clamp(100, 1000);
        });
        
        // Notify parent about speed change
        widget.onSpeedChanged(_currentSpeed);
      },
      child: Container(
        width: double.infinity,
        height: 100,
        margin: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: Colors.grey[900],
          borderRadius: BorderRadius.circular(30),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              spreadRadius: 2,
              blurRadius: 5,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: LayoutBuilder(
          builder: (context, constraints) {
            return Stack(
              alignment: Alignment.centerLeft,
              children: [
                // Background indicator
                Positioned(
                  left: 0,
                  right: 0,
                  child: Container(
                    height: 10,
                    decoration: BoxDecoration(
                      color: Colors.grey[700],
                      borderRadius: BorderRadius.circular(5),
                    ),
                  ),
                ),
                
                // Filled portion
                Positioned(
                  left: 0,
                  child: Container(
                    width: constraints.maxWidth * percentage,
                    height: 10,
                    decoration: BoxDecoration(
                      color: Colors.amber,
                      borderRadius: BorderRadius.circular(5),
                    ),
                  ),
                ),
                
                // Slider handle
                Positioned(
                  left: constraints.maxWidth * percentage - 25,
                  child: Container(
                    width: 50,
                    height: 40,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          spreadRadius: 1,
                          blurRadius: 3,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Center(
                      child: Text(
                        '${_currentSpeed.round()} ms',
                        style: TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
                
                // Left label (Slow)
                const Positioned(
                  left: 10,
                  bottom: -25,
                  child: Text(
                    'Slow',
                    style: TextStyle(
                      color: Colors.white54,
                      fontSize: 12,
                    ),
                  ),
                ),
                
                // Right label (Fast)
                const Positioned(
                  right: 10,
                  bottom: -25,
                  child: Text(
                    'Fast',
                    style: TextStyle(
                      color: Colors.white54,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}