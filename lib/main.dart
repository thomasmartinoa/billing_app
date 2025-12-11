import 'package:flutter/material.dart';
import 'screens/home_screen.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Billing Dashboard',
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: Color(0xFF0B0E0F),
        floatingActionButtonTheme: FloatingActionButtonThemeData(
          backgroundColor: Color(0xFF00C59E),
        ),
      ),
      home: HomeScreen(),
    );
  }
}
