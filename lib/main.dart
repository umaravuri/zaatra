import 'package:flutter/material.dart';
import 'core/theme/app_theme.dart';
import 'views/screens/welcome_screen_1.dart';

void main() {
  runApp(const ZaatraApp());
}

class ZaatraApp extends StatelessWidget {
  const ZaatraApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Zaatra',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: const WelcomeScreen(),
    );
  }
}
