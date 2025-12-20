import 'package:billing_app/screens/welcome.dart';
import 'package:billing_app/screens/home_screen.dart';
import 'package:billing_app/screens/screen_setup.dart';
import 'package:billing_app/services/auth_service.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    const primary = Color(0xFF17F1C5);

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Billing App',
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: const Color(0xFF050608),
        colorScheme: ColorScheme.fromSeed(
          seedColor: primary,
          brightness: Brightness.dark,
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: const Color(0xFF1B1E22),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: Color(0xFF252A30)),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: Color(0xFF252A30)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(color: primary),
          ),
          labelStyle: const TextStyle(fontSize: 13),
        ),
      ),
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