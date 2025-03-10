import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:work_with_faces/utils/appconstants.dart';
import 'package:work_with_faces/widgets/custombutton.dart';
import 'package:work_with_faces/widgets/face_detector_view.dart';

import '../providers/auth_provider.dart';
import '../services/homescreen.dart';
import '../utils/appcolors.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isPasswordVisible = true;
  bool _capturingFace = false;
  List<double>? _capturedFaceEmbeddings;

  @override
  void dispose() {
    // TODO: implement dispose
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();

    super.dispose();
  }

  void _toggleFaceCapture() {
    setState(() {
      _capturingFace = !_capturingFace;
    });
  }

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;

    if (_capturedFaceEmbeddings == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please capture your face first'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final success = await authProvider.registerUser(
      name: _nameController.text.trim(),
      email: _emailController.text.trim(),
      password: _passwordController.text,
      faceEmbedding: _capturedFaceEmbeddings!,
    );

    if (success) {
      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const HomeScreen()),
        );
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(authProvider.errorMessage)),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Sign UP")),
      body: _capturingFace ? FaceDetectorView(
          onFaceDetected: (List<double> faceEmbedding) {
            setState(() {
              _capturedFaceEmbeddings = faceEmbedding;
              _capturingFace = false;
            });

            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Face captured successfully!'),
                backgroundColor: AppColors.success,
              ),
            );
          },
          onCancel: _toggleFaceCapture) : SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(AppConstants.defaultPadding),
          child: Column(
            children: [
              SizedBox(height: 16),
              GestureDetector(
                onTap: _toggleFaceCapture,
                child: CircleAvatar(
                  radius: 60,
                  backgroundColor:
                  _capturedFaceEmbeddings != null
                      ? AppColors.primary
                      : AppColors.textLight.withOpacity(0.2),
                  child:
                  _capturedFaceEmbeddings != null
                      ? Icon(Icons.check, size: 50, color: Colors.white)
                      : Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      Icon(
                        Icons.face,
                        size: 40,
                        color: AppColors.textLight,
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Tap to Capture',
                        style: TextStyle(
                          color: AppColors.textLight,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 24),
              Form(
                key: _formKey,
                child: Column(
                  children: [
                    // Name field
                    TextFormField(
                      controller: _nameController,
                      decoration: const InputDecoration(
                        labelText: 'Full Name',
                        prefixIcon: Icon(Icons.person_outline),
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Email field
                    TextFormField(
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      decoration: const InputDecoration(
                        labelText: 'Email',
                        prefixIcon: Icon(Icons.email_outlined),
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Password field
                    TextFormField(
                      controller: _passwordController,
                      obscureText: !_isPasswordVisible,
                      decoration: InputDecoration(
                        labelText: 'Password',
                        prefixIcon: const Icon(Icons.lock_outlined),
                        border: const OutlineInputBorder(),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _isPasswordVisible
                                ? Icons.visibility_off
                                : Icons.visibility,
                          ),
                          onPressed: () {
                            setState(() {
                              _isPasswordVisible = !_isPasswordVisible;
                            });
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              // Register button
              Custombutton(
                text: 'Register',
                isLoading: false,
                onPressed: _register,
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}