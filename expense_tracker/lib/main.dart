import 'package:expense_tracker/controllers/auth_controllers.dart';
import 'package:expense_tracker/controllers/theme_controller.dart';
//import 'package:expense_tracker/controllers/expenses_controllers.dart';
//import 'package:expense_tracker/controllers/login_controllers.dart';
import 'package:expense_tracker/routes.dart';
import 'package:expense_tracker/screens/homescreen.dart';
import 'package:expense_tracker/screens/login_page.dart';
import 'package:expense_tracker/screens/signup_page.dart'; // ← if you have this
import 'package:flutter/material.dart';
import 'package:get/get.dart';

void main() {
  final themeController = Get.put(ThemeController());
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Expense Tracker',
      debugShowCheckedModeBanner: false,
       theme: ThemeController.lightTheme,
      darkTheme: ThemeController.darkTheme,
      themeMode: ThemeMode.dark,
     
          
      initialBinding: AppBinding(),
      initialRoute: AppRoutes.login,
      getPages: [
        GetPage(name: AppRoutes.login, page: () => LoginScreen()),
        GetPage(
          name: AppRoutes.signup,
          page: () => SignupScreen(),
        ), // ← if you have this
        GetPage(
          name: AppRoutes.home,
          page: () => const HomeScreen(),
        ), // ← this was commented out!
      ],
    );
  }
}
