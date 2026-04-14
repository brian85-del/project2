import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;

class AuthController extends GetxController {
  // Text controllers
  final loginEmailController = TextEditingController();
  final loginPasswordController = TextEditingController();

  // Observable state
  final obscureLoginPassword = true.obs;
  final isLoading = false.obs;

  // ── User data ────────────────────────────────────────────────────────
  final userId = RxInt(0);
  final fullName = ''.obs;
  final username = ''.obs;
  final email = ''.obs;
  final phone = ''.obs;

  @override
  void onClose() {
    loginEmailController.dispose();
    loginPasswordController.dispose();
    super.onClose();
  }

  // ── Validators ───────────────────────────────────────────────────────
  String? validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) return 'Email is required';
    if (!GetUtils.isEmail(value.trim())) return 'Enter a valid email address';
    return null;
  }

  String? validatePassword(String? value) {
    if (value == null || value.isEmpty) return 'Password is required';
    if (value.length < 6) return 'Password must be at least 6 characters';
    return null;
  }

  // ── Login ────────────────────────────────────────────────────────────
  Future<void> login(GlobalKey<FormState> formKey) async {
    if (!formKey.currentState!.validate()) return;

    isLoading.value = true;
    try {
      final response = await http.post(
        Uri.parse('http://127.0.0.1/expenses/login.php'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': loginEmailController.text.trim(),
          'password': loginPasswordController.text.trim(),
        }),
      );

      // ADD THIS TEMPORARY PRINT:
      print("SERVER RESPONSE: '${response.body}'");

      if (response.body.isEmpty) {
        throw Exception("The server returned an empty response.");
      }

      jsonDecode(response.body);
      // ... rest of your code} catch (e) {
      Get.snackbar(
        'Error',
        'Could not connect to server',
        backgroundColor: const Color(0xFFFF6B6B),
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  // ── Logout ───────────────────────────────────────────────────────────
  void logout() {
    userId.value = 0;
    fullName.value = '';
    username.value = '';
    email.value = '';
    phone.value = '';
    loginEmailController.clear();
    loginPasswordController.clear();
    Get.offAllNamed('/login');
  }
}
