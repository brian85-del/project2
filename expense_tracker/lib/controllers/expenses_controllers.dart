import 'package:expense_tracker/screens/expenses.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ExpenseController extends GetxController {
  // ── Text controllers ──────────────────────────────────────────────────────
  final titleController = TextEditingController();
  final amountController = TextEditingController();

  // ── Observable state ──────────────────────────────────────────────────────
  final expenses = <Expense>[].obs;
  final selectedCategory = 'Food'.obs;
  final selectedDate = DateTime.now().obs;

  // ── Derived values ────────────────────────────────────────────────────────
  double get totalSpent => expenses.fold(0.0, (sum, e) => sum + e.amount);

  // ── Category helpers ──────────────────────────────────────────────────────
  final categories = [
    'Food',
    'Transport',
    'Shopping',
    'Bills',
    'Entertainment',
    'Health',
    'Other',
  ];

  final categoryIcons = <String, IconData>{
    'Food': Icons.restaurant,
    'Transport': Icons.directions_car,
    'Shopping': Icons.shopping_bag,
    'Bills': Icons.receipt_long,
    'Entertainment': Icons.movie,
    'Health': Icons.favorite,
    'Other': Icons.category,
  };

  final categoryColors = <String, Color>{
    'Food': const Color(0xFFFF6B6B),
    'Transport': const Color(0xFF4ECDC4),
    'Shopping': const Color(0xFFFFE66D),
    'Bills': const Color(0xFF95E1D3),
    'Entertainment': const Color(0xFFF38181),
    'Health': const Color(0xFF6BCB77),
    'Other': const Color(0xFFA8A8B3),
  };

  // ── Actions ───────────────────────────────────────────────────────────────

  void addExpense(GlobalKey<FormState> formKey) {
    if (!formKey.currentState!.validate()) return;

    final amount = double.tryParse(amountController.text);
    if (amount == null || amount <= 0) {
      Get.snackbar(
        'Error',
        'Please enter a valid amount',
        backgroundColor: const Color(0xFFFF6B6B),
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    expenses.insert(
      0,
      Expense(
        title: titleController.text.trim(),
        amount: amount,
        category: selectedCategory.value,
        date: selectedDate.value,
      ),
    );

    _clearForm();
    Get.back(); // close Add Expense screen
  }

  void deleteExpense(int index) => expenses.removeAt(index);

  void setCategory(String cat) => selectedCategory.value = cat;

  void setDate(DateTime date) => selectedDate.value = date;

  void _clearForm() {
    titleController.clear();
    amountController.clear();
    selectedCategory.value = 'Food';
    selectedDate.value = DateTime.now();
  }

  // ── Validation ────────────────────────────────────────────────────────────
  String? validateTitle(String? v) {
    if (v == null || v.trim().isEmpty) return 'Title is required';
    return null;
  }

  String? validateAmount(String? v) {
    if (v == null || v.isEmpty) return 'Amount is required';
    final n = double.tryParse(v);
    if (n == null || n <= 0) return 'Enter a valid amount';
    return null;
  }

  @override
  void onClose() {
    titleController.dispose();
    amountController.dispose();
    super.onClose();
  }
}
