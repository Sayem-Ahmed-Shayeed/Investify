import 'package:get/get.dart';

import '../../features/auth/controller/auth_controller.dart';
import '../../features/chat/controller/chat_controller.dart';
import '../../features/home/controller/nav_bar_controller.dart';
import '../../features/post_idea/controller/post_idea_controller.dart';
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
    Get.put(PostIdeaController());
    Get.put(ChatController());
  }
}
