import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:investify/features/auth/controller/auth_controller.dart';
import 'package:investify/features/home/view/navbar/bottom_nav_bar.dart';
import 'package:investify/features/home/view/tabs/home_tab.dart';
import 'package:investify/features/home/view/tabs/sandbox_tab.dart';
import 'package:investify/features/home/view/tabs/messages_tab.dart';
import 'package:investify/features/home/view/tabs/calendar_tab.dart';
import 'package:investify/features/settings/controller/theme_controller.dart';
import 'package:investify/utils/theme/app_colors.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;

  final List<Widget> _tabs = const [
    HomeTab(),
    SandboxTab(),
    MessagesTab(),
    CalendarTab(),
  ];

  void _onTabChanged(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final themeController = Get.find<ThemeController>();
    final authController = Get.find<AuthController>();
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text('Investify', style: theme.textTheme.headlineMedium),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          Obx(
            () => IconButton(
              icon: Icon(
                themeController.isDarkMode ? Icons.light_mode : Icons.dark_mode,
              ),
              onPressed: themeController.toggleTheme,
              tooltip: themeController.isDarkMode
                  ? 'Switch to Light Mode'
                  : 'Switch to Dark Mode',
            ),
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: authController.logout,
            tooltip: 'Logout',
          ),
        ],
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: isDark
                ? [AppColors.gradientTopDark, AppColors.gradientBottomDark]
                : [AppColors.gradientTopLight, AppColors.gradientBottomLight],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: IndexedStack(index: _currentIndex, children: _tabs),
      ),
      bottomNavigationBar: BottomNavBar(
        currentIndex: _currentIndex,
        onTap: _onTabChanged,
      ),
    );
  }
}
