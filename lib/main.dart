import 'package:flutter/material.dart';

void main() {
  runApp(const RyboApp());
}

class RyboApp extends StatelessWidget {
  const RyboApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'RyboKalkulator',
      theme: ThemeData(
        brightness: Brightness.dark,
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      home: const Scaffold(
        body: Center(
          child: Text('RyboKalkulator MVP'),
        ),
      ),
    );
  }
}