import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:work_with_faces/screens/loginscreen.dart';
import 'package:work_with_faces/utils/appconstants.dart';

import '../providers/auth_provider.dart';
import '../utils/appcolors.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    print("test:initState");
    _initialize();
  }

  Future<void> _initialize() async {
    print('test:initialize');

    await Provider.of<AuthProvider>(context, listen: false).initialize();
    await Future.delayed(Duration(seconds: 2));
    print('test:initialize.f');

    if (mounted) {
      print('test:initialize>');
      Navigator.of(
        context,
      ).pushReplacement(MaterialPageRoute(builder: (_) => LoginScreen()));
    }
  }

  @override
  Widget build(BuildContext context) {
    print("test:build");
    return Scaffold(
      appBar: AppBar(title: Text('')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.face_retouching_natural,
              size: 80,
              color: AppColors.primary,
            ),
            SizedBox(height: 24),
            Text(
              AppConstants.appName,
              style: Theme.of(context).textTheme.headlineLarge,
            ),
            SizedBox(height: 48),
            CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
            ),
          ],
        ),
      ),
    );
  }
}
