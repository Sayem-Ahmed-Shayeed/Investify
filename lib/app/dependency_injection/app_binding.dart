import 'package:get/get.dart';

import '../../features/auth/controller/auth_controller.dart';
import '../../features/chat/controller/chat_controller.dart';
import '../../features/home/controller/nav_bar_controller.dart';
import '../../features/post_idea/controller/post_idea_controller.dart';
import '../../features/profile/controller/profile_controller.dart';
import '../../features/sandbox/controller/sandbox_controller.dart';
import '../../features/settings/controller/theme_controller.dart';

class AppBinding extends Bindings {
  @override
  void dependencies() {
    if (!Get.isRegistered<ThemeController>()) {
      Get.put(ThemeController());
    }

    // Auth controller
    Get.put(AuthController());
    Get.put(NavBarController());
    Get.put(PostIdeaController());
    Get.put(ChatController());
    Get.put(SandboxController());
    Get.lazyPut(() => ProfileController());
  }
}
