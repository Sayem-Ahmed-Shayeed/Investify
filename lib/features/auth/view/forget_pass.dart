import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:investify/features/auth/controller/auth_controller.dart';
import 'package:investify/features/settings/controller/theme_controller.dart';
import 'package:investify/utils/sizes/size.dart';
import 'package:investify/utils/theme/app_colors.dart';

import 'widgets/input_field.dart';

class ForgetPasswordScreen extends StatelessWidget {
  const ForgetPasswordScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<AuthController>();
    final themeController = Get.find<ThemeController>();
    final theme = Theme.of(context);
    final isDark = Get.isDarkMode;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios,
            color: isDark
                ? AppColors.textPrimaryDark
                : AppColors.textPrimaryLight,
          ),
          onPressed: () {
            controller.resetEmailSent.value = false;
            Get.back();
          },
        ),
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
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              child: Obx(
                () => controller.resetEmailSent.value
                    ? _EmailSentCard(
                        controller: controller,
                        theme: theme,
                        isDark: isDark,
                      )
                    : _ForgetPasswordCard(
                        controller: controller,
                        theme: theme,
                        isDark: isDark,
                      ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _EmailSentCard extends StatelessWidget {
  final AuthController controller;
  final ThemeData theme;
  final bool isDark;

  const _EmailSentCard({
    required this.controller,
    required this.theme,
    required this.isDark,
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
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color.fromRGBO(76, 175, 80, 0.1),
              borderRadius: BorderRadius.circular(50),
            ),
            child: const Icon(
              Icons.mark_email_read_outlined,
              size: 50,
              color: Colors.green,
            ),
          ),
          const SizedBox(height: RomRomSizes.spaceBetweenElements),
          Text("Email Sent!", style: theme.textTheme.headlineMedium),
          const SizedBox(height: RomRomSizes.spaceBetweenItem),
          Text(
            "We've sent a password reset link to",
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyMedium,
          ),
          const SizedBox(height: RomRomSizes.small),
          Text(
            controller.email.value,
            textAlign: TextAlign.center,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: RomRomSizes.spaceBetweenElements),
          Text(
            "Please check your inbox and click the link\nto reset your password.",
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyMedium,
          ),
          const SizedBox(height: RomRomSizes.spaceBetweenElements * 2),

          // Back to login button
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              onPressed: () {
                controller.resetEmailSent.value = false;
                controller.clearFields();
                Get.back();
              },
              child: Text(
                "Back to Sign In",
                style: theme.textTheme.titleMedium?.copyWith(
                  color: AppColors.buttonTextLight,
                ),
              ),
            ),
          ),

          const SizedBox(height: RomRomSizes.medium),

          // Resend button
          TextButton(
            onPressed: () {
              controller.resetEmailSent.value = false;
            },
            child: Text(
              "Didn't receive email? Try again",
              style: theme.textTheme.bodyMedium?.copyWith(
                decoration: TextDecoration.underline,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ForgetPasswordCard extends StatelessWidget {
  final AuthController controller;
  final ThemeData theme;
  final bool isDark;

  const _ForgetPasswordCard({
    required this.controller,
    required this.theme,
    required this.isDark,
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
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isDark
                  ? AppColors.inputFillDark
                  : AppColors.inputFillLight,
              borderRadius: BorderRadius.circular(50),
            ),
            child: Icon(
              Icons.lock_reset,
              size: 50,
              color: theme.iconTheme.color,
            ),
          ),
          const SizedBox(height: RomRomSizes.spaceBetweenElements),
          Text("Reset Password", style: theme.textTheme.headlineMedium),
          const SizedBox(height: RomRomSizes.spaceBetweenItem),
          Text(
            "Enter your email address and we'll send you\na link to reset your password.",
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyMedium,
          ),
          const SizedBox(height: RomRomSizes.spaceBetweenElements * 2),

          // Email field
          InputField(
            hint: "Email",
            icon: Icons.email,
            onChanged: (v) => controller.email.value = v,
          ),

          const SizedBox(height: RomRomSizes.spaceBetweenElements),

          // Reset button
          SizedBox(
            width: double.infinity,
            height: 50,
            child: Obx(
              () => ElevatedButton(
                onPressed: controller.isLoading.value
                    ? null
                    : controller.sendPasswordResetEmail,
                child: controller.isLoading.value
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CupertinoActivityIndicator(),
                      )
                    : Text(
                        "Send Reset Link",
                        style: theme.textTheme.titleMedium?.copyWith(
                          color: AppColors.buttonTextLight,
                        ),
                      ),
              ),
            ),
          ),

          const SizedBox(height: RomRomSizes.spaceBetweenElements),

          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                "Remember your password?",
                style: theme.textTheme.bodyMedium,
              ),
              TextButton(
                onPressed: () => Get.back(),
                child: Text(
                  "Sign In",
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
