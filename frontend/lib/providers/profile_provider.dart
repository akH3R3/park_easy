import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'map_provider.dart';

class ProfileProvider with ChangeNotifier {
  bool isEditing = false;
  File? profileImage;

  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final phoneController = TextEditingController();
  final addressController = TextEditingController();
  final vehicleController = TextEditingController();
  final timeController = TextEditingController();
  final zoneController = TextEditingController();

  ProfileProvider() {
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final prefs = await SharedPreferences.getInstance();

    nameController.text = prefs.getString('name') ?? 'John Doe';
    emailController.text = prefs.getString('email') ?? 'johndoe@example.com';
    phoneController.text = prefs.getString('phone') ?? '+91 98765 43210';
    addressController.text = prefs.getString('address') ?? '123 Smart Street, Mumbai, India';
    vehicleController.text = prefs.getString('vehicle') ?? 'Honda City - MH12AB1234';
    timeController.text = prefs.getString('time') ?? '9 AM - 6 PM';
    zoneController.text = prefs.getString('zone') ?? 'Zone A';

    String? imagePath = prefs.getString('profile_image_path');
    if (imagePath != null && imagePath.isNotEmpty) {
      profileImage = File(imagePath);
    }

    notifyListeners();
  }

  Future<void> saveUserData(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setString('name', nameController.text);
    await prefs.setString('email', emailController.text);
    await prefs.setString('phone', phoneController.text);
    await prefs.setString('address', addressController.text);
    await prefs.setString('vehicle', vehicleController.text);
    await prefs.setString('time', timeController.text);
    await prefs.setString('zone', zoneController.text);

    if (profileImage != null) {
      await prefs.setString('profile_image_path', profileImage!.path);
    }

    final mapProvider = Provider.of<MapProvider>(context, listen: false);
    mapProvider.updateProfileImage(profileImage);
    mapProvider.updateUserName(nameController.text);
  }

  void toggleEditing(BuildContext context) {
    if (isEditing) saveUserData(context);
    isEditing = !isEditing;
    notifyListeners();
  }

  void updateProfileImage(File image) {
    profileImage = image;
    notifyListeners();
  }
}
