import 'package:flutter/material.dart';
import 'core/config/app_env.dart';
import 'core/theme/app_theme.dart';
import 'views/screens/welcome_screen_1.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await AppEnv.init();
  runApp(const ZaatraNewUserApp());
}

class ZaatraNewUserApp extends StatelessWidget {
  const ZaatraNewUserApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Zaatra - New User Flow',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: const WelcomeScreen(),
    );
  }
}
