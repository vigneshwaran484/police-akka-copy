import 'package:flutter/material.dart';
import 'screens/dashboard_screen.dart';
import 'screens/login_screen.dart';

void main() {
  runApp(const PoliceDashboardApp());
}

class PoliceDashboardApp extends StatelessWidget {
  const PoliceDashboardApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Tamil Nadu Police Dashboard',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: const Color(0xFF1E3A8A),
        fontFamily: 'Roboto',
      ),
      home: const PoliceLoginScreen(),
    );
  }
}

