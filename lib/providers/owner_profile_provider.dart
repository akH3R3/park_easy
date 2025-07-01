import 'dart:io';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_auth/firebase_auth.dart';

class OwnerProfileProvider extends ChangeNotifier {
  bool isEditing = false;
  File? profileImage;

  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final phoneController = TextEditingController();
  final businessController = TextEditingController();
  final addressController = TextEditingController();
  final lotsController = TextEditingController();

  Future<void> loadOwnerData({required String defaultName, required String defaultEmail}) async {
    final prefs = await SharedPreferences.getInstance();
    final currentUser = FirebaseAuth.instance.currentUser;

    nameController.text = currentUser?.displayName ?? prefs.getString('owner_name') ?? defaultName;
    emailController.text = currentUser?.email ?? prefs.getString('owner_email') ?? defaultEmail;
    phoneController.text = prefs.getString('owner_phone') ?? '+91 98765 43210';
    businessController.text = prefs.getString('owner_business') ?? 'Urban Parking Co.';
    addressController.text = prefs.getString('owner_address') ?? '123 Business Rd, Delhi';
    lotsController.text = prefs.getString('owner_lots') ?? '5';

    final imagePath = prefs.getString('owner_profile_image');
    if (imagePath != null) {
      profileImage = File(imagePath);
    }

    notifyListeners();
  }

  Future<void> saveOwnerData() async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setString('owner_name', nameController.text);
    await prefs.setString('owner_phone', phoneController.text);
    await prefs.setString('owner_business', businessController.text);
    await prefs.setString('owner_address', addressController.text);
    await prefs.setString('owner_lots', lotsController.text);

    if (profileImage != null) {
      await prefs.setString('owner_profile_image', profileImage!.path);
    }

    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      await user.updateDisplayName(nameController.text);
      await user.reload();
    }

    notifyListeners();
  }

  void toggleEditing() {
    if (isEditing) {
      saveOwnerData();
    }
    isEditing = !isEditing;
    notifyListeners();
  }

  void updateProfileImage(File file) {
    profileImage = file;
    notifyListeners();
  }

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    phoneController.dispose();
    businessController.dispose();
    addressController.dispose();
    lotsController.dispose();
    super.dispose();
  }
}
