import 'package:flutter/material.dart';
import 'core/config/app_env.dart';
import 'core/theme/app_theme.dart';
import 'views/screens/role_selection_screen_27.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await AppEnv.init();
  runApp(const ZaatraExistingUserApp());
}

class ZaatraExistingUserApp extends StatelessWidget {
  const ZaatraExistingUserApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Zaatra - Existing User Flow',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: const RoleSelectionScreen(isExistingUser: true),
    );
  }
}
