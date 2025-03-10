import 'package:flutter/material.dart';
import 'package:work_with_faces/screens/loginscreen.dart';
import 'package:work_with_faces/screens/signupscreen.dart';
import 'package:work_with_faces/screens/splash_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Work with Faces',
      home: SplashScreen(),
    );
  }
}
