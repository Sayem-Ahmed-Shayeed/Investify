import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:investify/features/settings/controller/theme_controller.dart';
import 'package:investify/utils/sizes/size.dart';
import 'package:investify/utils/theme/app_colors.dart';

import '../controller/auth_controller.dart';
import 'widgets/input_field.dart';

class RegisterScreen extends StatelessWidget {
  const RegisterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<AuthController>();
    final themeController = Get.find<ThemeController>();
    final theme = Theme.of(context);
    final isDark = Get.isDarkMode;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        scrolledUnderElevation: 0,
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios,
            color: isDark
                ? AppColors.textPrimaryDark
                : AppColors.textPrimaryLight,
          ),
          onPressed: () => Get.back(),
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
              padding: const EdgeInsets.symmetric(vertical: 20),
              child: _RegisterCard(
                controller: controller,
                theme: theme,
                isDark: isDark,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _RegisterCard extends StatelessWidget {
  final AuthController controller;
  final ThemeData theme;
  final bool isDark;

  const _RegisterCard({
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
        borderRadius: BorderRadius.circular(MySizes.roundedBoxCorner),
        border: Border.all(
          color: isDark ? AppColors.cardBorderDark : AppColors.cardBorderLight,
          width: 0.2,
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isDark
                  ? AppColors.inputFillDark
                  : AppColors.inputFillLight,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              Icons.person_add,
              size: MySizes.xxxxl,
              color: theme.iconTheme.color,
            ),
          ),
          const SizedBox(height: MySizes.spaceBetweenElements),
          Text("Create Account", style: theme.textTheme.headlineMedium),
          const SizedBox(height: MySizes.spaceBetweenItem),
          Text(
            "Join us to start your investment journey",
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyMedium,
          ),
          const SizedBox(height: MySizes.spaceBetweenElements * 2),

          // Name field
          InputField(
            hint: "Full Name",
            icon: Icons.person,
            onChanged: (v) => controller.name.value = v,
          ),
          const SizedBox(height: MySizes.medium),

          // Email field
          InputField(
            hint: "Email",
            icon: Icons.email,
            onChanged: (v) => controller.email.value = v,
          ),
          const SizedBox(height: MySizes.medium),

          // Age field
          InputField(
            hint: "Age",
            icon: Icons.cake,
            keyboardType: TextInputType.number,
            onChanged: (v) => controller.age.value = int.tryParse(v) ?? 0,
          ),
          const SizedBox(height: MySizes.medium),

          // Password field
          Obx(
            () => InputField(
              hint: "Password",
              icon: Icons.lock,
              obscure: controller.obscurePassword.value,
              suffix: IconButton(
                icon: Icon(
                  controller.obscurePassword.value
                      ? Icons.visibility_off
                      : Icons.visibility,
                ),
                onPressed: controller.togglePassword,
              ),
              onChanged: (v) => controller.password.value = v,
            ),
          ),
          const SizedBox(height: MySizes.medium),

          // Confirm password field
          Obx(
            () => InputField(
              hint: "Confirm Password",
              icon: Icons.lock_outline,
              obscure: controller.obscureConfirmPassword.value,
              suffix: IconButton(
                icon: Icon(
                  controller.obscureConfirmPassword.value
                      ? Icons.visibility_off
                      : Icons.visibility,
                ),
                onPressed: controller.toggleConfirmPassword,
              ),
              onChanged: (v) => controller.confirmPassword.value = v,
            ),
          ),
          const SizedBox(height: MySizes.spaceBetweenElements),

          // NID Card Image Picker
          _NidCardPicker(controller: controller, theme: theme, isDark: isDark),

          const SizedBox(height: MySizes.spaceBetweenElements),

          // Register button
          SizedBox(
            width: double.infinity,
            height: 50,
            child: Obx(
              () => ElevatedButton(
                onPressed: controller.isLoading.value
                    ? null
                    : controller.register,
                child: controller.isLoading.value
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Text(
                        "Create Account",
                        style: theme.textTheme.titleMedium?.copyWith(
                          color: AppColors.buttonTextLight,
                        ),
                      ),
              ),
            ),
          ),

          const SizedBox(height: MySizes.spaceBetweenElements),

          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                "Already have an account?",
                style: theme.textTheme.bodyMedium,
              ),
              TextButton(
                onPressed: () {
                  controller.clearFields();
                  Get.back();
                },
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

class _NidCardPicker extends StatelessWidget {
  final AuthController controller;
  final ThemeData theme;
  final bool isDark;

  const _NidCardPicker({
    required this.controller,
    required this.theme,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("NID Card Image", style: theme.textTheme.titleMedium),
        const SizedBox(height: MySizes.small),
        Obx(
          () => GestureDetector(
            onTap: controller.pickNidCardImage,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isDark
                    ? AppColors.inputFillDark
                    : AppColors.inputFillLight,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: isDark
                      ? AppColors.inputBorderDark
                      : AppColors.inputBorderLight,
                  width: 1,
                ),
              ),
              child: controller.nidCardFileName.value != null
                  ? Row(
                      children: [
                        Icon(Icons.image, color: theme.iconTheme.color),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            controller.nidCardFileName.value!,
                            style: theme.textTheme.bodyMedium,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close),
                          onPressed: controller.clearNidCardImage,
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                        ),
                      ],
                    )
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.upload_file, color: theme.iconTheme.color),
                        const SizedBox(width: 8),
                        Text(
                          "Tap to upload NID Card",
                          style: theme.textTheme.bodyMedium,
                        ),
                      ],
                    ),
            ),
          ),
        ),
      ],
    );
  }
}
