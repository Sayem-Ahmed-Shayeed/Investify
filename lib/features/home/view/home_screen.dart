import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:investify/features/auth/controller/auth_controller.dart';
import 'package:investify/features/settings/controller/theme_controller.dart';
import 'package:investify/utils/sizes/size.dart';
import 'package:investify/utils/theme/app_colors.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final themeController = Get.find<ThemeController>();
    final authController = Get.find<AuthController>();
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Investify',
          style: theme.textTheme.headlineMedium,
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          Obx(
            () => IconButton(
              icon: Icon(
                themeController.isDarkMode
                    ? Icons.light_mode
                    : Icons.dark_mode,
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
        child: SafeArea(
          child: Center(
            child: _WelcomeCard(theme: theme, isDark: isDark, user: user),
          ),
        ),
      ),
    );
  }
}

class _WelcomeCard extends StatelessWidget {
  final ThemeData theme;
  final bool isDark;
  final User? user;

  const _WelcomeCard({
    required this.theme,
    required this.isDark,
    required this.user,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 360,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: isDark ? AppColors.cardDark : AppColors.cardLight,
        borderRadius: BorderRadius.circular(RomRomSizes.roundedBoxCorner),
        border: Border.all(
          color: isDark ? AppColors.cardBorderDark : AppColors.cardBorderLight,
          width: 0.2,
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: isDark ? AppColors.inputFillDark : AppColors.inputFillLight,
              borderRadius: BorderRadius.circular(50),
            ),
            child: Icon(
              Icons.check_circle_outline,
              size: 60,
              color: Colors.green,
            ),
          ),
          const SizedBox(height: RomRomSizes.spaceBetweenElements),
          Text(
            "Welcome!",
            style: theme.textTheme.headlineMedium,
          ),
          const SizedBox(height: RomRomSizes.spaceBetweenItem),
          Text(
            "You're successfully logged in",
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyMedium,
          ),
          const SizedBox(height: RomRomSizes.spaceBetweenElements),

          // User info
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isDark ? AppColors.inputFillDark : AppColors.inputFillLight,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.email_outlined, size: 20, color: theme.iconTheme.color),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        user?.email ?? 'No email',
                        style: theme.textTheme.bodyMedium,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(
                      Icons.verified,
                      size: 20,
                      color: user?.emailVerified == true ? Colors.green : Colors.orange,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      user?.emailVerified == true ? 'Email Verified' : 'Email Not Verified',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: user?.emailVerified == true ? Colors.green : Colors.orange,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: RomRomSizes.spaceBetweenElements),

          Text(
            "Start exploring your investment opportunities!",
            textAlign: TextAlign.center,
            style: theme.textTheme.bodySmall,
          ),
        ],
      ),
    );
  }
}
