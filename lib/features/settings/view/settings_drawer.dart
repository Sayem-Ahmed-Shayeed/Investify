import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:investify/features/auth/controller/auth_controller.dart';
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
    final authController = Get.find<AuthController>();
    String currUserEmail = authController.getCurrentUserEmail;
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
          GestureDetector(
            onTap: () => _showProfileImageOptions(context, authController),
            child: Obx(() {
              final imageUrl = authController.cachedProfileImageUrl.value;
              final isUploading = authController.isUploadingProfileImage.value;

              return Stack(
                children: [
                  CircleAvatar(
                    radius: RomRomSizes.xxxl,
                    backgroundColor: theme.colorScheme.primary.withValues(
                      alpha: 0.2,
                    ),
                    backgroundImage: imageUrl != null
                        ? NetworkImage(imageUrl)
                        : null,
                    child: imageUrl == null
                        ? Icon(
                            Icons.person,
                            size: RomRomSizes.xxxl,
                            color: theme.colorScheme.primary,
                          )
                        : null,
                  ),
                  if (isUploading)
                    Positioned.fill(
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.black45,
                          shape: BoxShape.circle,
                        ),
                        child: const Center(
                          child: SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primary,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.camera_alt,
                        size: 14,
                        color: theme.colorScheme.onPrimary,
                      ),
                    ),
                  ),
                ],
              );
            }),
          ),
          const SizedBox(width: RomRomSizes.containerPadding),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Obx(
                  () => Text(
                    authController.cachedUserName.value,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
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

  void _showProfileImageOptions(
    BuildContext context,
    AuthController authController,
  ) {
    final theme = Theme.of(context);
    final hasImage = authController.cachedProfileImageUrl.value != null;

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: theme.colorScheme.outline.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              ListTile(
                leading: Icon(
                  Icons.photo_library,
                  color: theme.colorScheme.primary,
                ),
                title: const Text('Choose from gallery'),
                onTap: () {
                  Navigator.pop(context);
                  authController.pickAndUploadProfileImage();
                },
              ),
              if (hasImage)
                ListTile(
                  leading: Icon(
                    Icons.delete_outline,
                    color: theme.colorScheme.error,
                  ),
                  title: Text(
                    'Remove photo',
                    style: TextStyle(color: theme.colorScheme.error),
                  ),
                  onTap: () {
                    Navigator.pop(context);
                    authController.removeProfileImage();
                  },
                ),
              ListTile(
                leading: Icon(Icons.close, color: theme.colorScheme.onSurface),
                title: const Text('Cancel'),
                onTap: () => Navigator.pop(context),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
