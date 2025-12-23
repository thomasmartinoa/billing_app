import 'package:billing_app/screens/welcome.dart';
import 'package:billing_app/screens/home_screen.dart';
import 'package:billing_app/screens/screen_setup.dart';
import 'package:billing_app/services/auth_service.dart';
import 'package:billing_app/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Firebase
  await Firebase.initializeApp();
  
  // Enable offline persistence for better performance
  FirebaseFirestore.instance.settings = const Settings(
    persistenceEnabled: true,
    cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED,
  );
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Billing App',
      theme: AppTheme.darkTheme,
      home: const AuthWrapper(),
    );
  }
}

/// Wrapper to handle auth state changes
class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        // Show loading while checking auth state
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(color: Color(0xFF17F1C5)),
            ),
          );
        }

        // User not logged in
        if (!snapshot.hasData || snapshot.data == null) {
          return const WelcomePage();
        }

        // User is logged in, check if setup is complete
        return const SetupChecker();
      },
    );
  }
}

/// Check if user has completed shop setup
class SetupChecker extends StatelessWidget {
  const SetupChecker({super.key});

  @override
  Widget build(BuildContext context) {
    final authService = AuthService();

    return FutureBuilder<bool>(
      future: authService.isSetupComplete(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(color: Color(0xFF17F1C5)),
            ),
          );
        }

        final isSetupComplete = snapshot.data ?? false;

        if (isSetupComplete) {
          return HomeScreen();
        } else {
          return const ScreenSetup();
        }
      },
    );
  }
}