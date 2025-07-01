import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:park_easy/providers/map_provider.dart';
import 'package:park_easy/providers/owner_profile_provider.dart';
import 'package:park_easy/providers/profile_provider.dart';
import 'package:park_easy/providers/speech_provider.dart';
import 'package:park_easy/providers/user_bottom_navbar.dart';
import 'package:park_easy/screens/owner_dashboard_screen.dart';
import 'package:park_easy/screens/owner_profile_screen.dart';
import 'package:park_easy/screens/splash_screen.dart';
import 'package:park_easy/screens/user_home_screen.dart';
import 'package:park_easy/services/noti_service.dart';
import 'package:park_easy/widgets/voice_command_listener.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '/screens/splash_screen.dart';
import 'firebase_options.dart';
import '../providers/image_provider.dart';
import '../providers/slot_provider.dart';
import 'package:park_easy/providers/booking_provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '/screens/auth_screen.dart';


Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await dotenv.load(fileName: ".env");
  } catch (e) {
    print('Failed to load .env file: $e');
    print('Env loaded: ${dotenv.env}');
  }
  NotiService().initNotification();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => MapProvider()..init()),
        ChangeNotifierProvider(create: (_) => UserBottomNavBarProvider()),
        ChangeNotifierProvider(create: (_) => ProfileProvider()),
        ChangeNotifierProvider(create: (_) => SpeechProvider()),
        ChangeNotifierProvider(create: (_) => BookingProvider()),
        ChangeNotifierProvider(create: (_) => SlotProvider()),
        ChangeNotifierProvider(create: (_) => ImageUploadProvider()),
        ChangeNotifierProvider(create: (_) => OwnerProfileProvider()),
      ],
      child: Mainhome2(),
    ),
  );

}
class Mainhome2 extends StatelessWidget {
  const Mainhome2({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: SplashScreen(),
    );
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  Future<Widget> _getInitialScreen() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return AuthScreen();

    final prefs = await SharedPreferences.getInstance();
    final userType = prefs.getString('userType');

    if (userType == 'owner') {
      return OwnerDashboardScreen(user: user);
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
          debugShowCheckedModeBanner: false,
          theme: ThemeData(
            colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
          ),
          home: VoiceCommandListener(child: snapshot.data!),
        );
      },
    );
  }
}
