import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:investify/features/auth/controller/auth_controller.dart';
import 'package:investify/features/home/view/navbar/bottom_nav_bar.dart';
import 'package:investify/features/post_idea/view/post_idea_screen.dart';
import 'package:investify/features/settings/controller/theme_controller.dart';

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

    return Obx(() {
      return Scaffold(
        floatingActionButton: navBarController.currentTabIndex == 0
            ? OutlinedButton(
                style: OutlinedButton.styleFrom(
                  backgroundColor: theme.colorScheme.onSurface.withValues(
                    alpha: 0.7,
                  ),
                  foregroundColor: theme.colorScheme.surface,
                  side: BorderSide(color: theme.colorScheme.surface),
                ),
                onPressed: () => Get.to(() => const PostIdeaScreen()),
                child: Text("Add Post"),
              )
            : SizedBox(height: 0, width: 0),
        appBar: AppBar(
          title: Text('Investify', style: theme.textTheme.headlineMedium),
          centerTitle: true,
          backgroundColor: Colors.transparent,
          elevation: 0,
          actions: [
            IconButton(
              icon: Icon(
                themeController.isDarkMode ? Icons.light_mode : Icons.dark_mode,
              ),
              onPressed: themeController.toggleTheme,
              tooltip: themeController.isDarkMode
                  ? 'Switch to Light Mode'
                  : 'Switch to Dark Mode',
            ),
            IconButton(
              icon: const Icon(Icons.logout),
              onPressed: authController.logout,
              tooltip: 'Logout',
            ),
          ],
        ),
        body: SizedBox(
          width: double.infinity,
          height: double.infinity,
          child: IndexedStack(
            index: navBarController.currentTabIndex.value,
            sizing: StackFit.loose,
            children: navBarController.tabs,
          ),
        ),
        bottomNavigationBar: BottomNavBar(),
      );
    });
  }
}
