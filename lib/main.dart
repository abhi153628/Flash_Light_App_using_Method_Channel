
import 'package:flash_light_method_chanel/home_page.dart';
import 'package:flutter/material.dart';


/// Entry point of the application
void main() {
  runApp(const MyApp());
}

/// Root widget of the application
/// Configures the theme and initial route
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flashlight App',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const FlashlightPage(),
    );
  }
}

