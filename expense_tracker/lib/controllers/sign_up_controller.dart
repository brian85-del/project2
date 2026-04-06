import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;

class SignupController extends GetxController {
  // ── Text Controllers ────────────────────────────────────────────
  final signupNameController = TextEditingController();
  final signupEmailController = TextEditingController();
  final signupPasswordController = TextEditingController();
  final signupConfirmPasswordController = TextEditingController();
  final signupUsernameController = TextEditingController();
  final signupPhoneController = TextEditingController();

  // ── Observables ─────────────────────────────────────────────────
  final obscureSignupPassword = true.obs;
  final obscureConfirmPassword = true.obs;
  final isSignupLoading = false.obs;

  // ── Dispose ─────────────────────────────────────────────────────
  @override
  void onClose() {
    signupNameController.dispose();
    signupEmailController.dispose();
    signupPasswordController.dispose();
    signupConfirmPasswordController.dispose();
    signupUsernameController.dispose();
    signupPhoneController.dispose();

    super.onClose();
  }

  // ── Validators ──────────────────────────────────────────────────
  String? validateName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Full name is required';
    }
    if (value.trim().length < 2) {
      return 'Name must be at least 2 characters';
    }
    return null;
  }

  String? validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Email is required';
    }
    if (!GetUtils.isEmail(value.trim())) {
      return 'Enter a valid email address';
    }
    return null;
  }

  String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password is required';
    }
    if (value.length < 6) {
      return 'Password must be at least 6 characters';
    }
    return null;
  }

  String? validateUsername(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Username is required';
    }
    if (value.trim().length < 3) {
      return 'Username must be at least 3 characters';
    }
    return null;
  }

  String? validatePhone(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Phone number is required';
    }
    if (!GetUtils.isPhoneNumber(value.trim())) {
      return 'Enter a valid phone number';
    }
    return null;
  }

  String? validateConfirmPassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please confirm your password';
    }
    if (value != signupPasswordController.text) {
      return 'Passwords do not match';
    }
    return null;
  }

  // ── Signup Action ────────────────────────────────────────────────
  // ── Signup Action ────────────────────────────────────────────────
  Future<void> signup(GlobalKey<FormState> formKey) async {
    FocusManager.instance.primaryFocus?.unfocus();

    if (!formKey.currentState!.validate()) return;

    isSignupLoading.value = true;

    try {
      final url = Uri.parse('http://127.0.0.1/expenses/register.php');

      final Map<String, dynamic> signupData = {
        "name": signupNameController.text.trim(),
        "email": signupEmailController.text.trim(),
        "password": signupPasswordController.text,
        "username": signupNameController.text.trim().toLowerCase().replaceAll(
          ' ',
          '_',
        ),
        "phone": signupPhoneController.text.trim(), // Ensure this matches your API requirements
      };

      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode(signupData),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        // 1. Clear the fields so they are empty if the user returns later
        _clearFields();

        // 2. Show a success message
        Get.snackbar(
          'Success 🎉',
          'Account created! Please log in.',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: const Color(0xFF7C3AED),
          colorText: Colors.white,
          duration: const Duration(seconds: 3),
        );

        // 3. NAVIGATE BACK TO LOGIN
        // Use Get.back() if Signup was opened via Get.to()
        // Use Get.offNamed('/login') to explicitly go to the login route
        Get.offNamed('/login');
      } else {
        final errorBody = jsonDecode(response.body);
        throw errorBody['message'] ?? 'Check your data and try again.';
      }
    } catch (e) {
      Get.snackbar(
        'Sign-up failed',
        e.toString(),
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: const Color(0xFFFF6B6B),
        colorText: Colors.white,
      );
    } finally {
      isSignupLoading.value = false;
    }
  }

  // ── Helpers ──────────────────────────────────────────────────────
  void _clearFields() {
    signupNameController.clear();
    signupEmailController.clear();
    signupPasswordController.clear();
    signupConfirmPasswordController.clear();
  }
}
