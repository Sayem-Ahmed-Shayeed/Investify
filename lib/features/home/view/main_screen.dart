import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:investify/features/auth/controller/auth_controller.dart';
import 'package:investify/features/home/view/navbar/bottom_nav_bar.dart';
import 'package:investify/features/settings/controller/theme_controller.dart';
import 'package:investify/utils/theme/app_colors.dart';

import '../controller/nav_bar_controller.dart';

class MainScreen extends StatelessWidget {
  const MainScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final themeController = Get.find<ThemeController>();
    final authController = Get.find<AuthController>();
    final navBarController = Get.find<NavBarController>();
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text('Investify', style: theme.textTheme.headlineMedium),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          Obx(
            () => IconButton(
              icon: Icon(
                themeController.isDarkMode ? Icons.light_mode : Icons.dark_mode,
              ),
              onPressed: themeController.toggleTheme,
              tooltip: themeController.isDarkMode
                  ? 'Switch to Light Mode'
                  : 'Switch to Dark Mode',
            ),
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: authController.logout,
            tooltip: 'Logout',
          ),
        ],
      ),
      body: Obx(
        () => Container(
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
          child: IndexedStack(
            index: navBarController.currentTabIndex.value,
            children: navBarController.tabs,
          ),
        ),
      ),
      bottomNavigationBar: BottomNavBar(),
    );
  }
}
