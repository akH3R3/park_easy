import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:park_easy/providers/map_provider.dart';
import 'package:park_easy/providers/profile_provider.dart';
import 'package:park_easy/providers/speech_provider.dart';
import 'package:park_easy/providers/user_bottom_navbar.dart';
import 'package:park_easy/screens/auth_screen.dart';
import 'package:park_easy/screens/dummy_owner_screen.dart';
import 'package:park_easy/screens/user_home_screen.dart';
import 'package:park_easy/services/noti_service.dart';
import 'package:park_easy/widgets/voice_command_listener.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await dotenv.load(fileName: ".env");
  } catch (e) {
    print('Failed to load .env file: $e');
  }

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  NotiService().initNotification();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => MapProvider()..init()),
        ChangeNotifierProvider(create: (_) => UserBottomNavBarProvider()),
        ChangeNotifierProvider(create: (_) => ProfileProvider()),
        ChangeNotifierProvider(create: (_) => SpeechProvider()),
      ],
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  Future<Widget> _getInitialScreen() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return AuthScreen();

    final prefs = await SharedPreferences.getInstance();
    final userType = prefs.getString('userType');

    if (userType == 'owner') {
      return DummyOwnerScreen();
    } else {
      return UserHomeScreen(email: user.email ?? '');
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _getInitialScreen(),
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const MaterialApp(
            home: Scaffold(body: Center(child: CircularProgressIndicator())),
          );
        }

        return MaterialApp(
          title: 'Park Easy',
          theme: ThemeData(
            colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
          ),
          home: VoiceCommandListener(child: snapshot.data!),
        );
      },
    );
  }
}
