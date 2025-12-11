import 'package:flutter/material.dart';
import 'screens/create_invoice_screen.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Invoice Demo',
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: Color(0xFF0B0E0F),
      ),
      home: CreateInvoiceScreen(),   // 👈 Opens your invoice screen
    );
  }
}
