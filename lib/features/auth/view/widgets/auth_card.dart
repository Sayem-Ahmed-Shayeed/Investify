import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:investify/features/auth/view/widgets/social_button.dart';
import 'package:investify/utils/sizes/size.dart';
import 'package:investify/utils/theme/app_colors.dart';

import '../../controller/auth_controller.dart';
import '../forget_pass.dart';
import '../register_screen.dart';
import 'input_field.dart';

class AuthCard extends StatelessWidget {
  const AuthCard({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<AuthController>();
    final theme = Theme.of(context);
    final isDark = Get.isDarkMode;

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
              Icons.login,
              size: MySizes.xxxxl,
              color: theme.iconTheme.color,
            ),
          ),
          const SizedBox(height: MySizes.spaceBetweenElements),
          Text("Sign in with email", style: theme.textTheme.headlineMedium),
          const SizedBox(height: MySizes.spaceBetweenItem),
          Text(
            "Make a new doc to bring your words, data,\nand teams together. For free",
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyMedium,
          ),
          const SizedBox(height: MySizes.spaceBetweenElements * 2),

          InputField(
            hint: "Email",
            icon: Icons.email,
            onChanged: (v) => controller.email.value = v,
          ),

          const SizedBox(height: MySizes.medium),

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

          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: () {
                controller.clearFields();
                Get.to(() => const ForgetPasswordScreen());
              },
              child: Text(
                "Forgot password?",
                style: theme.textTheme.bodyMedium,
              ),
            ),
          ),

          const SizedBox(height: MySizes.medium),

          SizedBox(
            width: double.infinity,
            height: 50,
            child: Obx(
              () => ElevatedButton(
                onPressed: controller.isLoading.value ? null : controller.login,
                child: controller.isLoading.value
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Text(
                        "Get Started",
                        style: theme.textTheme.titleMedium?.copyWith(
                          color: AppColors.buttonTextLight,
                        ),
                      ),
              ),
            ),
          ),

          const SizedBox(height: MySizes.spaceBetweenElements),
          Text("Or sign in with", style: theme.textTheme.bodyMedium),

          const SizedBox(height: 12),

          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: const [
              SocialButton(icon: Icons.g_mobiledata),
              SizedBox(width: MySizes.spaceBetweenItem),
              SocialButton(icon: Icons.facebook),
              SizedBox(width: MySizes.spaceBetweenItem),
              SocialButton(icon: Icons.apple),
            ],
          ),

          const SizedBox(height: MySizes.spaceBetweenElements),

          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text("Don't have an account?", style: theme.textTheme.bodyMedium),
              TextButton(
                onPressed: () {
                  controller.clearFields();
                  Get.to(() => const RegisterScreen());
                },
                child: Text(
                  "Sign Up",
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
