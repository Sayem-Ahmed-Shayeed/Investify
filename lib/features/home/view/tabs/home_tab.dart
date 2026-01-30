import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:investify/utils/sizes/size.dart';
import 'package:investify/utils/theme/app_colors.dart';

class HomeTab extends StatefulWidget {
  const HomeTab({super.key});

  @override
  State<HomeTab> createState() => _HomeTabState();
}

class _HomeTabState extends State<HomeTab> {
  bool _showWelcomeCard = true;

  void _closeWelcomeCard() {
    setState(() {
      _showWelcomeCard = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final user = FirebaseAuth.instance.currentUser;

    return SafeArea(
      child: Center(
        child: _showWelcomeCard
            ? _WelcomeCard(
                theme: theme,
                isDark: isDark,
                user: user,
                onClose: _closeWelcomeCard,
              )
            : Text("Welcome back!", style: theme.textTheme.headlineMedium),
      ),
    );
  }
}

class _WelcomeCard extends StatelessWidget {
  final ThemeData theme;
  final bool isDark;
  final User? user;
  final VoidCallback onClose;

  const _WelcomeCard({
    required this.theme,
    required this.isDark,
    required this.user,
    required this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          width: 360,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: isDark ? AppColors.cardDark : AppColors.cardLight,
            borderRadius: BorderRadius.circular(RomRomSizes.roundedBoxCorner),
            border: Border.all(
              color: isDark
                  ? AppColors.cardBorderDark
                  : AppColors.cardBorderLight,
              width: 0.2,
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: isDark
                      ? AppColors.inputFillDark
                      : AppColors.inputFillLight,
                  borderRadius: BorderRadius.circular(50),
                ),
                child: const Icon(
                  Icons.check_circle_outline,
                  size: 60,
                  color: Colors.green,
                ),
              ),
              const SizedBox(height: RomRomSizes.spaceBetweenElements),
              Text("Welcome!", style: theme.textTheme.headlineMedium),
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
                  color: isDark
                      ? AppColors.inputFillDark
                      : AppColors.inputFillLight,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.email_outlined,
                          size: 20,
                          color: theme.iconTheme.color,
                        ),
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
                          color: user?.emailVerified == true
                              ? Colors.green
                              : Colors.orange,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          user?.emailVerified == true
                              ? 'Email Verified'
                              : 'Email Not Verified',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: user?.emailVerified == true
                                ? Colors.green
                                : Colors.orange,
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
        ),
        // Close button
        Positioned(
          top: 8,
          right: 8,
          child: GestureDetector(
            onTap: onClose,
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: isDark
                    ? AppColors.inputFillDark
                    : AppColors.inputFillLight,
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.close, size: 20, color: theme.iconTheme.color),
            ),
          ),
        ),
      ],
    );
  }
}
