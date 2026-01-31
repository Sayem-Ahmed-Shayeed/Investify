import 'package:get/get.dart';

import '../../features/auth/controller/auth_controller.dart';
import '../../features/home/controller/nav_bar_controller.dart';
import '../../features/settings/controller/theme_controller.dart';

class AppBinding extends Bindings {
  @override
  void dependencies() {
    // Theme controller (already initialized in main, just ensure it's available)
    if (!Get.isRegistered<ThemeController>()) {
      Get.put(ThemeController());
    }

    // Auth controller
    Get.put(AuthController());
    Get.put(NavBarController());

    // TODO:: add other controllers here if needed
  }
}
