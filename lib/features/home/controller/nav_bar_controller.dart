import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:investify/features/profile/view/profile.dart';

import '../view/tabs/calendar_tab.dart';
import '../view/tabs/home_tab.dart';
import '../view/tabs/messages_tab.dart';
import '../view/tabs/sandbox_tab.dart';

class NavBarController extends GetxController {
  final currentTabIndex = 0.obs;
  final List<Widget> tabs = const [
    HomeTab(),
    SandboxTab(),
    MessagesTab(),
    CalendarTab(),
    Profile(),
  ];

  onTabChanged(int index) {
    currentTabIndex.value = index;
  }
}
