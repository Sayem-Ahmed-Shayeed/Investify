import 'package:get/get.dart';

import '../../auth/controller/auth_controller.dart';
import '../../auth/services/user_service.dart';

/// Controller for the Edit Profile page
class EditProfileController extends GetxController {
  final UserService _userService = UserService();

  // Form fields
  final name = ''.obs;
  final email = ''.obs;
  final age = Rxn<int>();
  final profileImageUrl = Rxn<String>();

  // State
  final isLoading = false.obs;
  final isSaving = false.obs;
  final isLoadingData = true.obs;

  @override
  void onInit() {
    super.onInit();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    try {
      isLoadingData.value = true;
      final userData = await _userService.getCurrentUser();
      if (userData != null) {
        name.value = userData['name'] as String? ?? '';
        email.value = userData['email'] as String? ?? '';
        age.value = userData['age'] as int?;
        profileImageUrl.value = userData['profileImageUrl'] as String?;
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to load profile data',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoadingData.value = false;
    }
  }

  Future<void> saveProfile() async {
    // Validation
    if (name.value.trim().isEmpty) {
      Get.snackbar(
        'Validation Error',
        'Name cannot be empty',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    if (age.value != null && (age.value! < 13 || age.value! > 120)) {
      Get.snackbar(
        'Validation Error',
        'Age must be between 13 and 120',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    try {
      isSaving.value = true;

      await _userService.updateUser(
        name: name.value.trim(),
        age: age.value,
      );

      // Update global state
      final authController = Get.find<AuthController>();
      authController.cachedUserName.value = name.value.trim();

      Get.snackbar(
        'Success',
        'Profile updated successfully',
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 1),
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to update profile: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isSaving.value = false;
    }
  }

  void updateName(String value) => name.value = value;
  void updateAge(String value) {
    if (value.isEmpty) {
      age.value = null;
    } else {
      age.value = int.tryParse(value);
    }
  }
}
