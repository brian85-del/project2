import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeController extends GetxController {
  final isDarkMode = true.obs;

  @override
  void onInit() {
    super.onInit();
    _loadTheme();
  }

  Future<void> _loadTheme() async {
  final prefs = await SharedPreferences.getInstance();
  isDarkMode.value = prefs.getBool('isDarkMode') ?? true;
  Get.changeThemeMode(
    isDarkMode.value ? ThemeMode.dark : ThemeMode.light,
  );
}

  Future<void> toggleTheme() async {
  isDarkMode.value = !isDarkMode.value;
  Get.changeThemeMode(
    isDarkMode.value ? ThemeMode.dark : ThemeMode.light,
  );
}

  ThemeData get currentTheme => isDarkMode.value ? darkTheme : lightTheme;

  static final darkTheme = ThemeData(
    brightness: Brightness.dark,
    scaffoldBackgroundColor: const Color(0xFF1E1E2E),
    colorScheme: const ColorScheme.dark(
      primary: Color(0xFF7C3AED),
      surface: Color(0xFF2A2A3E),
    ),
  );

  static final lightTheme = ThemeData(
    brightness: Brightness.light,
    scaffoldBackgroundColor: const Color(0xFFF4F4F8),
    colorScheme: const ColorScheme.light(
      primary: Color(0xFF7C3AED),
      surface: Color(0xFFFFFFFF),
    ),
  );
}
