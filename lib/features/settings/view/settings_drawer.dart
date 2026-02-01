import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:investify/features/auth/controller/auth_controller.dart';
import 'package:investify/features/auth/services/user_service.dart';
import 'package:investify/features/settings/view/widgets/app_version.dart';
import 'package:investify/features/settings/view/widgets/build_divider.dart';
import 'package:investify/features/settings/view/widgets/build_settings_item.dart';
import 'package:investify/features/settings/view/widgets/dark_mode_item.dart';
import 'package:investify/features/settings/view/widgets/log_out_item.dart';
import 'package:investify/features/settings/view/widgets/section_title.dart';
import 'package:investify/features/settings/view/widgets/settings_group.dart';
import 'package:investify/utils/sizes/size.dart';

class SettingsDrawer extends StatelessWidget {
  const SettingsDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final authController = Get.find<AuthController>();

    return Drawer(
      width: MediaQuery.of(context).size.width * 0.8,
      backgroundColor: theme.colorScheme.surface,
      child: SafeArea(
        child: Column(
          children: [
            _buildHeader(context, theme),
            const SizedBox(height: RomRomSizes.medium),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(
                  horizontal: RomRomSizes.containerPadding,
                ),
                children: [
                  buildSectionTitle(theme, 'Preferences'),
                  SettingsGroup(
                    children: [
                      DarkModeItem(),
                      BuildDivider(),
                      BuildSettingsItem(
                        icon: Icons.notifications_outlined,
                        title: 'Notifications',
                        trailing: buildArrow(theme),
                        onTap: () {},
                      ),
                      BuildDivider(),
                      BuildSettingsItem(
                        icon: Icons.language_outlined,
                        title: 'Language',
                        subtitle: 'English',
                        trailing: buildArrow(theme),
                        onTap: () {},
                      ),
                    ],
                  ),
                  const SizedBox(height: RomRomSizes.xl),
                  buildSectionTitle(theme, 'Account'),
                  SettingsGroup(
                    children: [
                      BuildSettingsItem(
                        icon: Icons.person_outline,
                        title: 'Edit Profile',
                        trailing: buildArrow(theme),
                        onTap: () {},
                      ),
                      BuildDivider(),
                      BuildSettingsItem(
                        icon: Icons.lock_outline,
                        title: 'Privacy & Security',
                        trailing: buildArrow(theme),
                        onTap: () {},
                      ),
                      BuildDivider(),
                      BuildSettingsItem(
                        icon: Icons.help_outline,
                        title: 'Help & Support',
                        trailing: buildArrow(theme),
                        onTap: () {},
                      ),
                    ],
                  ),
                  const SizedBox(height: RomRomSizes.xl),
                  SettingsGroup(children: [LogOutItem()]),
                  buildAppVersion(theme),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, ThemeData theme) {
    String currUserEmail = Get.find<AuthController>().getCurrentUserEmail;
    return Container(
      padding: const EdgeInsets.all(RomRomSizes.xl),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: theme.colorScheme.outline.withValues(alpha: 0.1),
          ),
        ),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: RomRomSizes.xxxl,
            backgroundColor: theme.colorScheme.primary.withValues(alpha: 0.2),
            child: Icon(
              Icons.person,
              size: RomRomSizes.xxxl,
              color: theme.colorScheme.primary,
            ),
          ),
          const SizedBox(width: RomRomSizes.containerPadding),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                //this code displays the user name
                FutureBuilder<Map<String, dynamic>?>(
                  future: UserService().getCurrentUser(),
                  builder: (context, snapshot) {
                    String displayName = 'User';
                    if (snapshot.hasData && snapshot.data != null) {
                      displayName = snapshot.data!['name'] ?? 'User';
                    }
                    return Text(
                      displayName,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    );
                  },
                ),
                const SizedBox(height: RomRomSizes.spaceBetweenItem),
                Text(
                  currUserEmail,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () => Get.back(),
            icon: Icon(
              Icons.close,
              color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
            ),
          ),
        ],
      ),
    );
  }
}
