import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:investify/features/auth/controller/auth_controller.dart';
import 'package:investify/features/home/view/navbar/bottom_nav_bar.dart';
import 'package:investify/features/settings/controller/theme_controller.dart';
import 'package:investify/features/settings/view/settings_drawer.dart';

import '../controller/nav_bar_controller.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    final themeController = Get.find<ThemeController>();
    final authController = Get.find<AuthController>();
    final navBarController = Get.find<NavBarController>();
    final theme = Theme.of(context);

    return Obx(() {
      return Scaffold(
        key: _scaffoldKey,
        drawer: const SettingsDrawer(),
        appBar: AppBar(
          leading: IconButton(
            onPressed: () => _scaffoldKey.currentState?.openDrawer(),
            icon: const Icon(Icons.menu),
          ),
          title: Text('Investify', style: theme.textTheme.headlineMedium),
          centerTitle: true,
          backgroundColor: Colors.transparent,
          elevation: 0,
        ),
        body: SizedBox(
          width: double.infinity,
          height: double.infinity,
          child: IndexedStack(
            index: navBarController.currentTabIndex.value,
            sizing: StackFit.loose,
            children: navBarController.tabs,
          ),
        ),
        bottomNavigationBar: const BottomNavBar(),
      );
    });
  }
}
