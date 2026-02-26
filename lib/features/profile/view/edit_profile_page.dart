import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../utils/sizes/size.dart';
import '../../auth/controller/auth_controller.dart';
import '../controller/edit_profile_controller.dart';

/// Edit Profile page — accessible from Settings Drawer
class EditProfilePage extends StatelessWidget {
  const EditProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(EditProfileController());
    final authController = Get.find<AuthController>();
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Edit Profile',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Obx(() {
        if (controller.isLoadingData.value) {
          return const Center(child: CircularProgressIndicator());
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.all(MySizes.xl),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Profile Image
              _buildProfileImage(theme, authController),
              const SizedBox(height: MySizes.xxxl),

              // Name Field
              _buildTextField(
                theme: theme,
                label: 'Name',
                icon: Icons.person_outline,
                initialValue: controller.name.value,
                onChanged: controller.updateName,
              ),
              const SizedBox(height: MySizes.containerPadding),

              // Email Field (read-only)
              _buildTextField(
                theme: theme,
                label: 'Email',
                icon: Icons.email_outlined,
                initialValue: controller.email.value,
                readOnly: true,
                helperText: 'Email cannot be changed',
              ),
              const SizedBox(height: MySizes.containerPadding),

              // Age Field
              _buildTextField(
                theme: theme,
                label: 'Age',
                icon: Icons.cake_outlined,
                initialValue: controller.age.value?.toString() ?? '',
                onChanged: controller.updateAge,
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: MySizes.containerPadding),

              const SizedBox(height: MySizes.xxxl),

              // Save Button
              SizedBox(
                width: double.infinity,
                height: 52,
                child: Obx(
                  () => ElevatedButton(
                    onPressed: controller.isSaving.value
                        ? null
                        : controller.saveProfile,
                    child: controller.isSaving.value
                        ? const SizedBox(
                            height: 22,
                            width: 22,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Text(
                            'Save Changes',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                  ),
                ),
              ),
              const SizedBox(height: MySizes.xl),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildProfileImage(ThemeData theme, AuthController authController) {
    return GestureDetector(
      onTap: () => authController.pickAndUploadProfileImage(),
      child: Obx(() {
        final imageUrl = authController.cachedProfileImageUrl.value;
        final isUploading = authController.isUploadingProfileImage.value;

        return Stack(
          children: [
            CircleAvatar(
              radius: 56,
              backgroundColor: theme.colorScheme.primary.withValues(alpha: 0.2),
              backgroundImage: imageUrl != null ? NetworkImage(imageUrl) : null,
              child: imageUrl == null
                  ? Icon(
                      Icons.person,
                      size: 56,
                      color: theme.colorScheme.primary,
                    )
                  : null,
            ),
            if (isUploading)
              Positioned.fill(
                child: Container(
                  decoration: const BoxDecoration(
                    color: Colors.black45,
                    shape: BoxShape.circle,
                  ),
                  child: const Center(
                    child: SizedBox(
                      width: 28,
                      height: 28,
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
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: theme.colorScheme.surface,
                    width: 2,
                  ),
                ),
                child: Icon(
                  Icons.camera_alt,
                  size: 18,
                  color: theme.colorScheme.onPrimary,
                ),
              ),
            ),
          ],
        );
      }),
    );
  }

  Widget _buildTextField({
    required ThemeData theme,
    required String label,
    required IconData icon,
    required String initialValue,
    ValueChanged<String>? onChanged,
    bool readOnly = false,
    String? helperText,
    TextInputType? keyboardType,
    int maxLines = 1,
    int? maxLength,
  }) {
    return TextFormField(
      initialValue: initialValue,
      readOnly: readOnly,
      onChanged: onChanged,
      keyboardType: keyboardType,
      maxLines: maxLines,
      maxLength: maxLength,
      style: theme.textTheme.bodyLarge?.copyWith(
        color: readOnly
            ? theme.colorScheme.onSurface.withValues(alpha: 0.5)
            : null,
      ),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: theme.textTheme.bodyMedium,
        helperText: helperText,
        helperStyle: theme.textTheme.bodySmall?.copyWith(
          color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
        ),
        prefixIcon: Icon(icon, color: theme.colorScheme.primary),
        filled: true,
        fillColor: readOnly
            ? theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.3)
            : null,
      ),
    );
  }
}
