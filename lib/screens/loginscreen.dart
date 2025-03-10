import 'package:flutter/material.dart';
import 'package:work_with_faces/screens/signupscreen.dart';
import 'package:work_with_faces/services/homescreen.dart';
import 'package:work_with_faces/utils/appconstants.dart';
import 'package:work_with_faces/widgets/custombutton.dart';

import '../utils/appcolors.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool _isPasswordVisible = true;
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("")),
      body: Center(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(AppConstants.defaultPadding),
          child: Column(
            children: [
              Icon(
                Icons.face_retouching_natural,
                size: 72,
                color: AppColors.primary,
              ),
              SizedBox(height: 16),
              Text(
                'Welcome back',
                style: Theme.of(context).textTheme.headlineLarge,
              ),
              SizedBox(height: 8),
              Text(
                'Login to Continue',
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              SizedBox(height: 32),
              Form(
                key: _formKey,
                child: Column(
                  children: [
                    TextFormField(
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      decoration: InputDecoration(
                        labelText: 'Email',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    SizedBox(height: 16),
                    TextFormField(
                      controller: _passwordController,
                      obscureText: _isPasswordVisible,
                      decoration: InputDecoration(
                        labelText: 'Password',
                        prefixIcon: Icon(Icons.lock_outline),
                        border: OutlineInputBorder(),
                        suffixIcon: IconButton(
                          onPressed: () {
                            setState(() {
                              _isPasswordVisible = !_isPasswordVisible;
                            });
                          },
                          icon: Icon(
                            _isPasswordVisible
                                ? Icons.visibility_off
                                : Icons.visibility,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 24),
                    Custombutton(
                      text: 'login',
                      onPressed: () {
                        Navigator.pushReplacement(context, MaterialPageRoute(builder: (_)=> HomeScreen()));
                      },
                      isLoading: false,
                    ),
                    SizedBox(height: 16),
                    Custombutton(
                      text: "Login with face",
                      onPressed: () {},
                      isLoading: false,
                      isOutlined: true,
                    ),
                    SizedBox(height: 32),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "Don't have an account?",
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                        GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (_) => SignupScreen()),
                            );
                            // Navigate to registration screen
                          },
                          child: Text(
                            "Register",
                            style: Theme.of(context).textTheme.bodyLarge,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
