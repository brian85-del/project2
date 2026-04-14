import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;

class Expense {
  final int id;
  final String title;
  final String category;
  final double amount;
  final DateTime date;

  Expense({
    required this.id,
    required this.title,
    required this.category,
    required this.amount,
    required this.date,
  });

  factory Expense.fromJson(Map<String, dynamic> json) {
    return Expense(
      id: int.tryParse(json['id'].toString()) ?? 0,
      title: json['title'],
      category: json['category'],
      amount: double.tryParse(json['amount'].toString()) ?? 0.0,
      date: DateTime.tryParse(json['date']) ?? DateTime.now(),
    );
  }
}

class ExpenseController extends GetxController {
  final titleController = TextEditingController();
  final amountController = TextEditingController();

  final selectedCategory = ''.obs;
  final selectedDate = DateTime.now().obs;
  final isLoading = false.obs;

  final expenses = <Expense>[].obs;

  // ── Computed total ───────────────────────────────────────────────────
  double get totalSpent => expenses.fold(0.0, (sum, e) => sum + e.amount);

  // ── Categories ───────────────────────────────────────────────────────
  final List<String> categories = [
    'Food',
    'Transport',
    'Shopping',
    'Health',
    'Entertainment',
    'Bills',
    'Other',
  ];

  final Map<String, IconData> categoryIcons = {
    'Food': Icons.restaurant,
    'Transport': Icons.directions_car,
    'Shopping': Icons.shopping_bag,
    'Health': Icons.favorite,
    'Entertainment': Icons.movie,
    'Bills': Icons.receipt,
    'Other': Icons.more_horiz,
  };

  final Map<String, Color> categoryColors = {
    'Food': Color(0xFFFF6B6B),
    'Transport': Color(0xFF4ECDC4),
    'Shopping': Color(0xFFFFBE0B),
    'Health': Color(0xFF06D6A0),
    'Entertainment': Color(0xFFBB86FC),
    'Bills': Color(0xFF4F86C6),
    'Other': Color(0xFFA8A8B3),
  };

  FormFieldValidator<String>? get validateTitle => null;

  FormFieldValidator<String>? get validateAmount => null;

  void setCategory(String cat) => selectedCategory.value = cat;
  void setDate(DateTime date) => selectedDate.value = date;

  @override
  void onInit() {
    super.onInit();
    fetchExpenses();
  }

  // ── GET: Fetch all expenses ──────────────────────────────────────────
  Future<void> fetchExpenses() async {
    isLoading.value = true;
    try {
      final response = await http.get(
        Uri.parse('http://127.0.0.1/expenses/add_expenses.php'),
      );
      final data = jsonDecode(response.body);
      if (data['success']) {
        expenses.value = (data['data'] as List)
            .map((e) => Expense.fromJson(e))
            .toList();
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Could not fetch expenses',
        backgroundColor: const Color(0xFFFF6B6B),
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  // ── POST: Add new expense ────────────────────────────────────────────
  Future<void> addExpense(GlobalKey<FormState> formKey) async {
    if (!formKey.currentState!.validate()) return;

    if (selectedCategory.value.isEmpty) {
      Get.snackbar(
        'Category Required',
        'Please select a category',
        backgroundColor: const Color(0xFFFF6B6B),
        colorText: Colors.white,
      );
      return;
    }

    isLoading.value = true;
    try {
      final response = await http.post(
        Uri.parse('http://127.0.0.1/expenses/add_expenses.php'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'title': titleController.text.trim(),
          'category': selectedCategory.value,
          'amount': amountController.text.trim(),
          'date':
              '${selectedDate.value.year}-'
              '${selectedDate.value.month.toString().padLeft(2, '0')}-'
              '${selectedDate.value.day.toString().padLeft(2, '0')}',
        }),
      );

      final data = jsonDecode(response.body);

      if (data['success']) {
        await fetchExpenses(); // refresh list
        Get.back();
        Get.snackbar(
          'Success',
          'Expense added successfully',
          backgroundColor: const Color(0xFF7C3AED),
          colorText: Colors.white,
        );
        _clearForm();
      } else {
        Get.snackbar(
          'Error',
          data['message'] ?? 'Something went wrong',
          backgroundColor: const Color(0xFFFF6B6B),
          colorText: Colors.white,
        );
      }
    } catch (e) {
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

  // ── DELETE: Remove expense by index ─────────────────────────────────
  Future<void> deleteExpense(int index) async {
    final expenseToDelete = expenses[index];
    try {
      final response = await http.delete(
        Uri.parse('http://127.0.0.1/expenses/add_expenses.php'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'id': expenseToDelete.id}),
      );

      final data = jsonDecode(response.body);

      if (data['success']) {
        expenses.removeAt(index);
        Get.snackbar(
          'Deleted',
          'Expense removed successfully',
          backgroundColor: const Color(0xFF7C3AED),
          colorText: Colors.white,
        );
      } else {
        Get.snackbar(
          'Error',
          data['message'] ?? 'Could not delete expense',
          backgroundColor: const Color(0xFFFF6B6B),
          colorText: Colors.white,
        );
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Could not connect to server',
        backgroundColor: const Color(0xFFFF6B6B),
        colorText: Colors.white,
      );
    }
  }

  // ── Budget fields ────────────────────────────────────────────────────
  final RxDouble totalBudget = 0.0.obs;
  final RxMap<String, double> categoryBudgets = <String, double>{}.obs;
  final isBudgetLoading = false.obs;

  final String baseUrl = 'http://127.0.0.1/expenses/budget.php'; // ← your IP

  // ── Computed budget helpers ──────────────────────────────────────────
  double get projectedSpend {
    final now = DateTime.now();
    final daysInMonth = DateUtils.getDaysInMonth(now.year, now.month);
    if (now.day == 0) return 0;
    return (totalSpentThisMonth / now.day) * daysInMonth;
  }

  double get totalSpentThisMonth {
    final now = DateTime.now();
    return expenses
        .where((e) => e.date.month == now.month && e.date.year == now.year)
        .fold(0.0, (sum, e) => sum + e.amount);
  }

  double spentForCategory(String category) {
    final now = DateTime.now();
    return expenses
        .where(
          (e) =>
              e.category == category &&
              e.date.month == now.month &&
              e.date.year == now.year,
        )
        .fold(0.0, (sum, e) => sum + e.amount);
  }

  // ── GET budgets ──────────────────────────────────────────────────────
  Future<void> fetchBudgets(int userId) async {
    isBudgetLoading.value = true;
    try {
      final now = DateTime.now();
      final response = await http.get(
        Uri.parse(
          '$baseUrl/budget.php?action=get&user_id=$userId&month=${now.month}&year=${now.year}',
        ),
      );
      final data = jsonDecode(response.body);
      if (data['code'] == 1) {
        final map = Map<String, double>.from(
          (data['budgets'] as Map).map(
            (k, v) => MapEntry(k, (v as num).toDouble()),
          ),
        );
        totalBudget.value = map.remove('overall') ?? 0.0;
        categoryBudgets.value = map;
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Could not load budgets',
        backgroundColor: const Color(0xFFFF6B6B),
        colorText: Colors.white,
      );
    } finally {
      isBudgetLoading.value = false;
    }
  }

  // ── SAVE budgets ─────────────────────────────────────────────────────
  Future<bool> saveBudgets(
    int userId,
    double overall,
    Map<String, double> catBudgets,
  ) async {
    try {
      final now = DateTime.now();
      final allBudgets = {'overall': overall, ...catBudgets};
      final response = await http.post(
        Uri.parse('$baseUrl/budget.php'),
        body: {
          'action': 'save',
          'user_id': userId.toString(),
          'month': now.month.toString(),
          'year': now.year.toString(),
          'budgets': jsonEncode(allBudgets),
        },
      );
      final data = jsonDecode(response.body);
      if (data['code'] == 1) {
        totalBudget.value = overall;
        categoryBudgets.value = catBudgets;
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  // ── Helpers ──────────────────────────────────────────────────────────
  void _clearForm() {
    titleController.clear();
    amountController.clear();
    selectedCategory.value = '';
    selectedDate.value = DateTime.now();
  }

  @override
  void onClose() {
    titleController.dispose();
    amountController.dispose();
    super.onClose();
  }
}
