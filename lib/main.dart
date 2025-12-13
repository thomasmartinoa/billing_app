import 'package:flutter/material.dart';
import 'screens/invoice_receipt_screen.dart';

void main() {
  runApp(MainApp());
}

class MainApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Billing App',
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: const Color(0xFF0B0E0F),
      ),
      home: InvoiceReceiptScreen(),
    );
  }
}
