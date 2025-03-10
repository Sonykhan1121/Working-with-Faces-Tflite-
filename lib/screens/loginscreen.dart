import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:work_with_faces/providers/auth_provider.dart';
import 'package:work_with_faces/screens/signupscreen.dart';
import 'package:work_with_faces/services/homescreen.dart';
import 'package:work_with_faces/utils/appconstants.dart';
import 'package:work_with_faces/widgets/custombutton.dart';
import 'package:work_with_faces/widgets/face_detector_view.dart';

import '../utils/appcolors.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool _isPasswordVisible = false;
  bool _usingFaceAuth = false;
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    // TODO: implement dispose
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final success = await authProvider.loginWithEmailPassword(
      _emailController.text.trim(),
      _passwordController.text,
    );
    if (success) {
      if (mounted) {
        Navigator.of(
          context,
        ).pushReplacement(MaterialPageRoute(builder: (_) => HomeScreen()));
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(authProvider.errorMessage)));
      }
    }
  }

  Future<void> _handleFaceMatch(
    AuthProvider authProvider,
    dynamic result,
  ) async {
    if (result != null) {
      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const HomeScreen()),
        );
      }
    } else {
      setState(() => _usingFaceAuth = false);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'No matching face found. Please register or try again.',
            ),
            backgroundColor: AppColors.error,
          ),
        );
        if (mounted) {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (_) => const SignupScreen()),
          );
        }
      }
    }
  }

  void _toggleFaceAuth() {
    setState(() => _usingFaceAuth = !_usingFaceAuth);
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    return Scaffold(
      appBar: AppBar(title: Text("")),
      body:
          _usingFaceAuth
              ? FaceDetectorView(
                onFaceDetected: (List<double> faceEmbedding) async {
                  final matchedUser = await authProvider.loginWithFace(faceEmbedding);
                  _handleFaceMatch(authProvider, matchedUser);
                },
                onCancel: _toggleFaceAuth,
              )
              : Center(
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
                              validator: (value){
                                if(value!.isEmpty)
                                  {
                                    return 'Please enter your email';
                                  }

                              }
                              ,
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
                                validator: (value){
                                  if(value!.isEmpty)
                                  {
                                    return 'Please enter your password';
                                  }

                                }
                            ),
                            SizedBox(height: 24),
                            Custombutton(
                              text: 'login',
                              onPressed: _login,
                              isLoading: authProvider.isLoading,
                            ),
                            SizedBox(height: 16),
                            Custombutton(
                              text: "Login with face",
                              icon:Icons.face,
                              onPressed: _toggleFaceAuth,
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
                                      MaterialPageRoute(
                                        builder: (_) => SignupScreen(),
                                      ),
                                    );
                                    // Navigate to registration screen
                                  },
                                  child: Text(
                                    "Register",
                                    style:
                                        Theme.of(context).textTheme.bodyLarge,
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
