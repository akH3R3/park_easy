import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:park_easy/providers/booking_provider.dart';
import '../providers/image_provider.dart';
import '../providers/slot_provider.dart';
import 'package:park_easy/providers/map_provider.dart';
import 'package:park_easy/providers/profile_provider.dart';
import 'package:park_easy/providers/user_bottom_navbar.dart';
import 'package:park_easy/screens/owner_dashboard_screen.dart';
import 'package:park_easy/screens/splash_screen.dart';
import 'package:park_easy/screens/user_home_screen.dart';
import 'package:provider/provider.dart';
import '../services/noti_service.dart';

import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await dotenv.load(fileName: ".env");
  } catch (e) {
    print('🥲Failed to load .env file: $e');
    print('🥳 Env loaded: ${dotenv.env}');
  }
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  NotiService().initNotification();
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => MapProvider()..init()),
        ChangeNotifierProvider(create: (_) => UserBottomNavBarProvider()),
        ChangeNotifierProvider(create: (_) => ProfileProvider()),
        ChangeNotifierProvider(create: (_) => BookingProvider()),
        ChangeNotifierProvider(create: (_) => SlotProvider()),
        ChangeNotifierProvider(create: (_) => ImageUploadProvider()),
      ],
      child: MyApp(),
    ),
  );

}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      //home: MapScreen(email: "email@email.com"),
      // home: OwnerDashboardScreen(),
        home:const SplashScreen(),
    );

  }
}
