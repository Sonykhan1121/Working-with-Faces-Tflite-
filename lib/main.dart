import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:work_with_faces/providers/auth_provider.dart';
import 'package:work_with_faces/screens/splash_screen.dart';

void main() {
  runApp(
     MultiProvider(
       providers: [
         ChangeNotifierProvider(create: (_) => AuthProvider()),

       ],
       child: MyApp(),
     ),
  );
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
