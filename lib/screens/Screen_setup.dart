import 'package:flutter/material.dart';

class ScreenSetup extends StatefulWidget {
  const ScreenSetup({super.key});

  @override
  State<ScreenSetup> createState() => _ScreenSetupState();
}

class _ScreenSetupState extends State<ScreenSetup> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(child: Text('Setup Screen', style: TextStyle(fontSize: 24))),
    );
  }
}
