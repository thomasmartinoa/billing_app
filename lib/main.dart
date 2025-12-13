import 'package:billing_app/screens/welcome.dart';
import 'package:flutter/material.dart';

void main() {
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
      home: const WelcomePage(),
    );
  }
}
