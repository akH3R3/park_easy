import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:showcaseview/showcaseview.dart';
import 'package:local_auth/local_auth.dart';

class OwnerChecks {
  static Future<void> checkAndShowShowcase({
    required BuildContext context,
    required GlobalKey profileAvatarKey,
    required GlobalKey analyticsKey,
    required GlobalKey editKey,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    bool hasSeenShowcase = prefs.getBool('hasSeenShowcase') ?? false;

    if (!hasSeenShowcase) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ShowCaseWidget.of(context).startShowCase([
          profileAvatarKey,
          analyticsKey,
          editKey,
        ]);
      });
      await prefs.setBool('hasSeenShowcase', true);
    }
  }

  static Future<bool> authenticate(BuildContext context) async {
    final auth = LocalAuthentication();
    try {
      bool canCheckBiometrics = await auth.canCheckBiometrics;
      if (!canCheckBiometrics) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Biometric authentication not available'),
          ),
        );
        return false;
      }
      bool isAuthenticated = await auth.authenticate(
        localizedReason: 'Please authenticate to proceed',
        options: const AuthenticationOptions(
          biometricOnly: false,
          stickyAuth: true,
        ),
      );
      return isAuthenticated;
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Authentication error: \$e')),
      );
      return false;
    }
  }
}
