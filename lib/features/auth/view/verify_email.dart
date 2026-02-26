import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:investify/features/auth/controller/auth_controller.dart';
import 'package:investify/features/settings/controller/theme_controller.dart';
import 'package:investify/utils/sizes/size.dart';
import 'package:investify/utils/theme/app_colors.dart';

import '../../home/view/main_screen.dart';

class VerifyEmailScreen extends StatefulWidget {
  const VerifyEmailScreen({super.key});

  @override
  State<VerifyEmailScreen> createState() => _VerifyEmailScreenState();
}

class _VerifyEmailScreenState extends State<VerifyEmailScreen> {
  final controller = Get.find<AuthController>();
  bool _canResend = true;
  int _resendCooldown = 0;
  Timer? _verificationTimer;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _startVerificationCheck();
    });
  }

  void _startVerificationCheck() {
    _verificationTimer?.cancel();
    _verificationTimer = Timer.periodic(const Duration(seconds: 3), (_) async {
      final verified = await controller.checkEmailVerified();
      if (verified) {
        _verificationTimer?.cancel();
        Get.snackbar(
          'Success',
          'Email verified successfully!',
          snackPosition: SnackPosition.BOTTOM,
          duration: const Duration(seconds: 2),
          backgroundColor: Colors.green.shade100,
          colorText: Colors.green.shade900,
        );
        Get.offAll(() => const MainScreen());
      }
    });
  }

  @override
  void dispose() {
    _verificationTimer?.cancel();
    super.dispose();
  }

  Future<void> _resendEmail() async {
    if (!_canResend) return;

    await controller.sendEmailVerification();
    setState(() {
      _canResend = false;
      _resendCooldown = 60;
    });

    Future.doWhile(() async {
      await Future.delayed(const Duration(seconds: 1));
      if (mounted) {
        setState(() {
          _resendCooldown--;
          if (_resendCooldown <= 0) {
            _canResend = true;
          }
        });
      }
      return _resendCooldown > 0 && mounted;
    });
  }

  @override
  Widget build(BuildContext context) {
    final themeController = Get.find<ThemeController>();
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        automaticallyImplyLeading: false,
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
              child: _VerifyEmailCard(
                theme: theme,
                isDark: isDark,
                controller: controller,
                canResend: _canResend,
                resendCooldown: _resendCooldown,
                onResend: _resendEmail,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _VerifyEmailCard extends StatelessWidget {
  final ThemeData theme;
  final bool isDark;
  final AuthController controller;
  final bool canResend;
  final int resendCooldown;
  final VoidCallback onResend;

  const _VerifyEmailCard({
    required this.theme,
    required this.isDark,
    required this.controller,
    required this.canResend,
    required this.resendCooldown,
    required this.onResend,
  });

  @override
  Widget build(BuildContext context) {
    final email = FirebaseAuth.instance.currentUser?.email ?? '';

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
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isDark
                  ? AppColors.inputFillDark
                  : AppColors.inputFillLight,
              borderRadius: BorderRadius.circular(50),
            ),
            child: Icon(
              Icons.mark_email_unread_outlined,
              size: 50,
              color: theme.iconTheme.color,
            ),
          ),
          const SizedBox(height: MySizes.spaceBetweenElements),
          Text("Verify Your Email", style: theme.textTheme.headlineMedium),
          const SizedBox(height: MySizes.spaceBetweenItem),
          RichText(
            textAlign: TextAlign.center,
            text: TextSpan(
              children: [
                TextSpan(
                  text: "We've sent a verification link to: ",
                  style: theme.textTheme.bodyMedium,
                ),
                TextSpan(
                  text: email,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                TextSpan(
                  text: "\nPlease check your inbox and click the link.",
                  style: theme.textTheme.bodyMedium,
                ),
              ],
            ),
          ),
          const SizedBox(height: MySizes.spaceBetweenElements),

          // Loading indicator
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                width: 16,
                height: 16,
                child: CupertinoActivityIndicator(color: theme.primaryColor),
              ),
              const SizedBox(width: 8),
              Text(
                "Waiting for verification...",
                style: theme.textTheme.bodySmall,
              ),
            ],
          ),

          const SizedBox(height: MySizes.spaceBetweenElements * 2),

          // Resend button
          SizedBox(
            width: double.infinity,
            height: 50,
            child: OutlinedButton(
              onPressed: canResend ? onResend : null,
              style: OutlinedButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                canResend
                    ? "Resend Verification Email"
                    : "Resend in ${resendCooldown}s",
                style: theme.textTheme.titleMedium,
              ),
            ),
          ),

          const SizedBox(height: MySizes.medium),

          // Logout button
          TextButton(
            onPressed: controller.logout,
            child: Text(
              "Sign out and try again",
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
