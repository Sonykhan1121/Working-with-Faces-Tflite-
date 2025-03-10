import 'package:flutter/material.dart';

import 'package:work_with_faces/utils/appconstants.dart';

import '../models/user.dart';
import '../utils/appcolors.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final Map<String, dynamic> now = {
      'id': 1,
      'name': 'John Doe',
      'email': 'john.doe@example.com',
      'password': 'securePassword',
      'faceEmbedding': '0.1,0.2,0.3,0.4,0.5',
      // Example embedding as a comma-separated string
    };
    final User user = User.fromMap(now);

    Widget _buildInfoRow({
      required IconData icon,
      required String label,
      required String value,
    }) {
      return Padding(
        padding: EdgeInsets.symmetric(vertical: 8.0),
        child: Row(
          children: [
            Icon(icon, color: AppColors.primary),
            SizedBox(width: 16),
            Text(label, style: Theme.of(context).textTheme.bodyLarge),
            Spacer(),
            Text(
              value,
              style:TextStyle(
                fontSize : 16,
                fontWeight: FontWeight.bold,

              ) ,
            )
          ],
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Home'),
        backgroundColor: AppColors.primary,
        actions: [IconButton(icon: Icon(Icons.logout), onPressed: () {})],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(AppConstants.defaultPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(height: 24),
            CircleAvatar(
              radius: 60,
              backgroundColor: AppColors.primary,
              child: Text(
                user.name.substring(0, 1).toUpperCase(),
                style: TextStyle(
                  fontSize: 48,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
            SizedBox(height: 16),
            Text(
              user.name,
              style: Theme.of(context).textTheme.headlineLarge,
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 32),
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    Text(
                      'Account Information',
                      style: Theme.of(context).textTheme.headlineMedium,
                    ),
                    SizedBox(height: 16),
                    _buildInfoRow(icon: Icons.fingerprint, label: "User ID", value: "#${user.id}"),
                    Divider(),
                    _buildInfoRow(icon: Icons.face, label: "Face Recognition", value: "Enabled"),
                    Divider(),
                    _buildInfoRow(icon: Icons.login, label: 'Login Methods', value: "Email & Face"),
                  ],
                ),
              ),
            ),
            SizedBox(height: 24,),
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              color: AppColors.primary.withOpacity(0.1),
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    Icon(
                        Icons.security,
                      size : 48,
                      color: AppColors.primary,
                    ),
                    SizedBox(height: 16,),
                    Text(
                      'Secure Local Authentication',
                      style: Theme.of(context).textTheme.headlineMedium,
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height:8),
                    Text(
                      'Your biometric data is stored securely on your device and never shared with any external servers.',
                      style: Theme.of(context).textTheme.bodyLarge,
                      textAlign: TextAlign.center,
                    )


                  ],
                ),

              ),
            )
          ],
        ),
      ),
    );
  }
}
