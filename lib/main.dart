import 'package:flutter/material.dart'; // Flutter UI framework
import 'package:firebase_core/firebase_core.dart'; // Firebase initialize karne ke liye
import 'firebase_options.dart'; // Firebase config file

import 'splash.dart'; // Splash screen import
import 'home.dart'; // Home screen import
import 'login.dart'; // Login screen import
import 'habit_tracker_screen.dart';
import 'chat_screen.dart'; // Chat screen import
import 'notification_service.dart';

void main() async { // app ka starting point (async kyunki Firebase init ho raha hai)
  WidgetsFlutterBinding.ensureInitialized(); // Flutter engine ko initialize karta hai

    // ✅ Firebase INIT — untouched
  await Firebase.initializeApp( // Firebase initialize ho raha hai
    options: DefaultFirebaseOptions.currentPlatform, // platform specific config (android/web)
  );
  await NotificationService.init();
  final now = DateTime.now().add(const Duration(minutes: 1));

  await NotificationService.init();

  runApp(const MyApp()); // app start ho rahi hai MyApp se
}

class MyApp extends StatelessWidget { // root widget (stateless kyunki state change nahi ho rahi)
  const MyApp({super.key}); // constructor

  @override
  Widget build(BuildContext context) { // UI build function
    return MaterialApp( // main app wrapper jo puri app ko handle karta ha like main container of app
      debugShowCheckedModeBanner: false, // debug label remove on debugging.
      title: 'MindEase+', // app ka title
      theme: ThemeData( // app ka theme
        useMaterial3: true, // Material 3 design use (modern)
        scaffoldBackgroundColor: const Color(0xFFF6F7FB), // background color
      ),

      // ✅ SINGLE splash screen
      home: const SplashScreen(), // app start hone par splash screen open hogi

      routes: { // named routes (navigation ke liye)
        '/home': (_) => const HomePage(), // home route
        '/login': (_) => const LoginPage(), // login route
        '/diagnosis': (_) => const ChatScreen(), // diagnosis/chat route
      },
    );
  }
}