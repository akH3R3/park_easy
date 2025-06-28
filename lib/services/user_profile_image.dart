import 'dart:io';
import 'package:shared_preferences/shared_preferences.dart';
class ProfileImageService {
  static Future<File?> getProfileImage() async {
    final prefs = await SharedPreferences.getInstance();
    final path = prefs.getString('profile_image_path');
    if (path != null && path.isNotEmpty) {
      return File(path);
    }
    return null;
  }
}