import 'dart:io';

import 'package:app_settings/app_settings.dart';
import 'package:flutter/material.dart';

import '../screens/auth_screen.dart';
import '../screens/profile_screen.dart';

class UserProfileDrawer extends StatelessWidget {
  final String email;
  final File? profileImage;

  const UserProfileDrawer({super.key, required this.email,required this.profileImage});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: SafeArea(
        child: Column(
          children: [
            SizedBox(height: 20),
            CircleAvatar(
              radius: 40,
              backgroundColor: Colors.grey[200],
              backgroundImage: profileImage != null
                  ? FileImage(profileImage!)
                  : AssetImage('assets/images/default_profile.jpg')
                        as ImageProvider,
            ),
            SizedBox(height: 10),
            Text(
              "User Name",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.email, size: 16, color: Colors.grey[600]),
                SizedBox(width: 4),
                Text(email, style: TextStyle(color: Colors.grey[800])),
              ],
            ),
            Divider(),
            ListTile(
              leading: Icon(Icons.person),
              title: Text("Profile"),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const ProfileScreen(),
                  ),
                );
              },
            ),
            ListTile(
              leading: Icon(Icons.settings),
              title: Text("Settings"),
              onTap: () {
                AppSettings.openAppSettings();
              },
            ),
            ListTile(
              leading: Icon(Icons.logout),
              title: Text("Logout"),
              onTap: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (_) => AuthScreen()),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
