import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:expense_tracker/controllers/sign_up_controller.dart';

class SignupScreen extends StatelessWidget {
  SignupScreen({super.key});

  final SignupController auth = Get.find<SignupController>();

  final _formKey = GlobalKey<FormState>();
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
                const SizedBox(height: 20),
                GestureDetector(
                  onTap: () => Get.back(),
                  child: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: const Color(0xFF2A2A3E),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      Icons.arrow_back,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                ),
                const SizedBox(height: 32),
                const Text(
                  'Create account',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Start tracking your expenses today',
                  style: TextStyle(color: Colors.grey[500], fontSize: 15),
                ),
                const SizedBox(height: 36),

                _buildLabel('Full Name'),
                const SizedBox(height: 8),
                _buildField(
                  controller: auth.signupNameController,
                  hint: 'John Doe',
                  icon: Icons.person_outline,
                  validator: auth.validateName,
                ),

                const SizedBox(height: 20),
                _buildLabel('Username'),
                const SizedBox(height: 8),
                _buildField(
                  controller: auth.signupUsernameController,
                  hint: '@johndoe',
                  icon: Icons.alternate_email,
                  validator: auth.validateUsername,
                ),

                const SizedBox(height: 20),
                _buildLabel('Phone Number'),
                const SizedBox(height: 8),
                _buildField(
                  controller: auth.signupPhoneController,
                  hint: '+1 234 567 8900',
                  icon: Icons.phone_outlined,
                  keyboardType: TextInputType.phone,
                  validator: auth.validatePhone,
                ),

                const SizedBox(height: 20),
                _buildLabel('Email'),
                const SizedBox(height: 8),
                _buildField(
                  controller: auth.signupEmailController,
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
                    controller: auth.signupPasswordController,
                    hint: 'Min. 6 characters',
                    icon: Icons.lock_outline,
                    obscure: auth.obscureSignupPassword.value,
                    validator: auth.validatePassword,
                    suffix: IconButton(
                      icon: Icon(
                        auth.obscureSignupPassword.value
                            ? Icons.visibility_off_outlined
                            : Icons.visibility_outlined,
                        color: Colors.grey[500],
                        size: 20,
                      ),
                      onPressed: () => auth.obscureSignupPassword.toggle(),
                    ),
                  ),
                ),

                const SizedBox(height: 20),
                _buildLabel('Confirm Password'),
                const SizedBox(height: 8),
                Obx(
                  () => _buildField(
                    controller: auth.signupConfirmPasswordController,
                    hint: 'Repeat your password',
                    icon: Icons.lock_outline,
                    obscure: auth.obscureConfirmPassword.value,
                    validator: auth.validateConfirmPassword,
                    suffix: IconButton(
                      icon: Icon(
                        auth.obscureConfirmPassword.value
                            ? Icons.visibility_off_outlined
                            : Icons.visibility_outlined,
                        color: Colors.grey[500],
                        size: 20,
                      ),
                      onPressed: () => auth.obscureConfirmPassword.toggle(),
                    ),
                  ),
                ),

                const SizedBox(height: 36),
                Obx(
                  () => SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: auth.isSignupLoading.value
                          ? null
                          : () => auth.signup(_formKey),
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
                      child: auth.isSignupLoading.value
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                          : const Text(
                              'Create Account',
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
                      'Already have an account? ',
                      style: TextStyle(color: Colors.grey[500]),
                    ),
                    GestureDetector(
                      onTap: () => Get.back(),
                      child: const Text(
                        'Log in',
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
