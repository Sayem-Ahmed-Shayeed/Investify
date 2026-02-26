import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:investify/features/auth/view/widgets/auth_card.dart';
import 'package:investify/features/settings/controller/theme_controller.dart';
import 'package:investify/utils/theme/app_colors.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final themeController = Get.find<ThemeController>();
    final isDark = Get.isDarkMode;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          Obx(
            () => IconButton(
              icon: Icon(
                themeController.isDarkMode ? Icons.light_mode : Icons.dark_mode,
                color: isDark
                    ? AppColors.textPrimaryDark
                    : AppColors.textPrimaryLight,
              ),
              onPressed: themeController.toggleTheme,
            ),
          ),
        ],
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: isDark
                ? [AppColors.gradientTopDark, AppColors.gradientBottomDark]
                : [AppColors.gradientTopLight, AppColors.gradientBottomLight],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: const SafeArea(
          child: Center(child: SingleChildScrollView(child: AuthCard())),
        ),
      ),
    );
  }
}
