import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:investify/features/chat/controller/chat_controller.dart';
import 'package:investify/features/chat/view/chat_detail_screen.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'app/dependency_injection/app_binding.dart';
import 'features/auth/view/auth_gate.dart';
import 'features/settings/controller/theme_controller.dart';
import 'firebase_options.dart';
import 'utils/theme/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // Initialize SharedPreferences and ThemeController
  await SharedPreferences.getInstance();
  final themeController = Get.put(ThemeController());

  OneSignal.Debug.setLogLevel(OSLogLevel.verbose);
  OneSignal.initialize("cfdc4a9c-e3a1-4a1b-9d51-ae99f62e743f");
  OneSignal.Notifications.requestPermission(true);

  // Link OneSignal device to Firebase UID so include_external_user_ids works
  FirebaseAuth.instance.authStateChanges().listen((user) {
    if (user != null) {
      OneSignal.login(user.uid);
    } else {
      OneSignal.logout();
    }
  });

  // Handle notification tap → navigate to the correct chat room
  OneSignal.Notifications.addClickListener((event) {
    final data = event.notification.additionalData;
    if (data != null && data['type'] == 'chat_message') {
      final roomId = data['roomId'] as String?;
      final senderUid = data['senderUid'] as String?;
      final currentUid = FirebaseAuth.instance.currentUser?.uid ?? '';

      if (roomId != null && roomId.isNotEmpty) {
        // Ensure ChatController exists before navigating
        if (!Get.isRegistered<ChatController>()) return;

        Get.to(
          () => ChatDetailScreen(
            roomID: roomId,
            senderUid: currentUid,
            receiverUid: senderUid ?? '',
          ),
        );
      }
    }
  });

  OneSignal.Notifications.addForegroundWillDisplayListener((event) {
    // Show the notification in the foreground
    event.notification.display();
  });

  runApp(Investify(themeController: themeController));
}

class Investify extends StatelessWidget {
  final ThemeController themeController;

  const Investify({super.key, required this.themeController});

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => GetMaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Investify',
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: themeController.themeMode,
        initialBinding: AppBinding(),
        home: const AuthGate(),
      ),
    );
  }
}
