import 'dart:convert';

import 'package:expense_tracker/controllers/login_controllers.dart';
import 'package:expense_tracker/routes.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;

class LoginScreen extends StatelessWidget {
  LoginScreen({super.key});

  final AuthController auth = Get.find<AuthController>();
  final _formKey = GlobalKey<FormState>();

 Future<void> _handleLogin() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    auth.isLoading.value = true;

    try {
      final email = auth.loginEmailController.text.trim();
      final password = auth.loginPasswordController.text.trim();

      final uri = Uri.parse(
        'http://192.168.0.106/expenses/login.php',
      ); // ← your IP

      final response = await http.post(
        uri,
        body: {'email': email, 'password': password},
      );

      if (response.statusCode == 200) {
        final serverData = jsonDecode(response.body);
      if (serverData['code'] == 1) {
          final userId = serverData['user_id'];
          auth.userId.value = (userId is int)
              ? userId
              : int.parse(userId.toString()); // ✅ safe cast
          print('SAVED USER ID: ${auth.userId.value}'); // ← confirm it saved
          Get.toNamed(AppRoutes.home);
        }
        else {
          Get.snackbar(
            'Error',
            'Invalid credentials',
            backgroundColor: const Color(0xFFFF6B6B),
            colorText: Colors.white,
          );
        }
      } else {
        Get.snackbar(
          'Server Error',
          'An error occurred while logging in',
          backgroundColor: const Color(0xFFFF6B6B),
          colorText: Colors.white,
        );
      }
    } catch (e) {
  print('LOGIN ERROR: $e'); // ← add this
  Get.snackbar('Network Error', e.toString(), // ← show real error
      backgroundColor: const Color(0xFFFF6B6B), colorText: Colors.white);
} finally {
  auth.isLoading.value = false;
}
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1E1E2E),
      body: SafeArea( 
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 40),

                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    // ignore: deprecated_member_use
                    color: const Color(0xFF7C3AED).withOpacity(0.15),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Icon(
                    Icons.account_balance_wallet,
                    color: Color(0xFF7C3AED),
                    size: 32,
                  ),
                ),

                const SizedBox(height: 28),
                const Text(
                  'Welcome back',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Log in to your expense tracker',
                  style: TextStyle(color: Colors.grey[500], fontSize: 15),
                ),

                const SizedBox(height: 40),

                _buildLabel('Email'),
                const SizedBox(height: 8),
                _buildField(
                  controller: auth.loginEmailController,
                  hint: 'you@example.com',
                  icon: Icons.email_outlined,
                  keyboardType: TextInputType.emailAddress,
                  validator: auth.validateEmail,
                ),

                const SizedBox(height: 20),

                _buildLabel('Password'),
                const SizedBox(height: 8),
                Obx(
                  () => _buildField(
                    controller: auth.loginPasswordController,
                    hint: '••••••••',
                    icon: Icons.lock_outline,
                    obscure: auth.obscureLoginPassword.value,
                    validator: auth.validatePassword,
                    suffix: IconButton(
                      icon: Icon(
                        auth.obscureLoginPassword.value
                            ? Icons.visibility_off_outlined
                            : Icons.visibility_outlined,
                        color: Colors.grey[500],
                        size: 20,
                      ),
                      onPressed: () => auth.obscureLoginPassword.toggle(),
                    ),
                  ),
                ),

                const SizedBox(height: 36),

                Obx(
                  () => SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: auth.isLoading.value ? null : _handleLogin,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF7C3AED),
                        disabledBackgroundColor: const Color(
                          0xFF7C3AED,
                        // ignore: deprecated_member_use
                        ).withOpacity(0.5),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      child: auth.isLoading.value
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                          : const Text(
                              'Log In',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Don't have an account? ",
                      style: TextStyle(color: Colors.grey[500]),
                    ),
                    GestureDetector(
                      onTap: () => Get.toNamed(AppRoutes.signup),
                      child: const Text(
                        'Sign up',
                        style: TextStyle(
                          color: Color(0xFF7C3AED),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLabel(String text) => Text(
    text,
    style: const TextStyle(
      color: Colors.grey,
      fontSize: 13,
      fontWeight: FontWeight.w500,
    ),
  );

  Widget _buildField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    bool obscure = false,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
    Widget? suffix,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: obscure,
      keyboardType: keyboardType,
      style: const TextStyle(color: Colors.white),
      validator: validator,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: Colors.grey[600]),
        prefixIcon: Icon(icon, color: Colors.grey[600], size: 20),
        suffixIcon: suffix,
        filled: true,
        fillColor: const Color(0xFF2A2A3E),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        errorStyle: const TextStyle(color: Color(0xFFFF6B6B)),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF7C3AED), width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFFF6B6B), width: 1.5),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFFF6B6B), width: 1.5),
        ),
      ),
    );
  }
}
