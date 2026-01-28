import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'app/dependency_injection/app_binding.dart';
import 'features/auth/view/auth_gate.dart';
import 'features/settings/controller/theme_controller.dart';
import 'firebase_options.dart';
import 'utils/theme/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Initialize SharedPreferences and ThemeController
  await SharedPreferences.getInstance();
  final themeController = Get.put(ThemeController());

  // Wait for theme to load from prefs
  await Future.delayed(const Duration(milliseconds: 100));

  runApp(Investify(themeController: themeController));
}

class Investify extends StatelessWidget {
  final ThemeController themeController;

  const Investify({super.key, required this.themeController});

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => GetMaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Investify',
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: themeController.themeMode,
        initialBinding: AppBinding(),
        home: const AuthGate(),
      ),
    );
  }
}
