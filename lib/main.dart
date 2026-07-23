import 'package:flutter/material.dart';
import 'theme/app_theme.dart';
import 'screens/connexion_screen.dart';

void main() {
  runApp(const TontineManagerApp());
}

class TontineManagerApp extends StatelessWidget {
  const TontineManagerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Tontine Manager',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.theme,
      home: const ConnexionScreen(),
    );
  }
}
