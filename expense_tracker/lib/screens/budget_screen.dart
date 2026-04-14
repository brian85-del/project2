import 'package:expense_tracker/controllers/expenses_controllers.dart';
import 'package:expense_tracker/controllers/login_controllers.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class BudgetScreen extends StatelessWidget {
  const BudgetScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final expense = Get.find<ExpenseController>();
    final auth = Get.find<AuthController>();

    // Fetch budgets when screen opens
    WidgetsBinding.instance.addPostFrameCallback((_) {
      expense.fetchBudgets(auth.userId.value);
    });

    final now = DateTime.now();
    final daysInMonth = DateUtils.getDaysInMonth(now.year, now.month);
    final daysLeft = daysInMonth - now.day;
    final monthName = _monthName(now.month);

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0,
        title: Text('Budget',
            style: TextStyle(
                color: Theme.of(context).colorScheme.onSurface,
                fontWeight: FontWeight.bold)),
        iconTheme:
            IconThemeData(color: Theme.of(context).colorScheme.onSurface),
        actions: [
          TextButton.icon(
            onPressed: () => _showEditBottomSheet(context, expense, auth),
            icon: const Icon(Icons.edit_outlined,
                color: Color(0xFF7C3AED), size: 18),
            label: const Text('Edit',
                style: TextStyle(
                    color: Color(0xFF7C3AED), fontWeight: FontWeight.w600)),
          ),
        ],
      ),
      body: Obx(() {
        if (expense.isBudgetLoading.value) {
          return const Center(
              child: CircularProgressIndicator(color: Color(0xFF7C3AED)));
        }

        final total = expense.totalBudget.value;
        final spent = expense.totalSpentThisMonth;
        final progress = total > 0 ? (spent / total).clamp(0.0, 1.0) : 0.0;
        final remaining = total - spent;
        final projected = expense.projectedSpend;
        final avgPerDay = now.day > 0 ? spent / now.day : 0.0;

        return SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              // ── Month label ───────────────────────────────────────
              Center(
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEDE9FE),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text('$monthName ${now.year}',
                      style: const TextStyle(
                          color: Color(0xFF534AB7),
                          fontSize: 12,
                          fontWeight: FontWeight.w600)),
                ),
              ),

              const SizedBox(height: 16),

              // ── Overall budget card ───────────────────────────────
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF7C3AED), Color(0xFF4F46E5)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: total == 0
                    ? Column(
                        children: [
                          const Icon(Icons.savings_outlined,
                              color: Colors.white70, size: 36),
                          const SizedBox(height: 10),
                          const Text('No budget set yet',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold)),
                          const SizedBox(height: 4),
                          Text('Tap Edit to set your monthly budget',
                              style: TextStyle(
                                  color: Colors.white.withValues(alpha: 0.7),
                                  fontSize: 13)),
                        ],
                      )
                    : Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Overall budget',
                              style: TextStyle(
                                  color: Colors.white.withValues(alpha: 0.75),
                                  fontSize: 13)),
                          const SizedBox(height: 4),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.baseline,
                            textBaseline: TextBaseline.alphabetic,
                            children: [
                              Text('KES ${spent.toStringAsFixed(0)}',
                                  style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 28,
                                      fontWeight: FontWeight.bold)),
                              const SizedBox(width: 6),
                              Text('of ${total.toStringAsFixed(0)}',
                                  style: TextStyle(
                                      color:
                                          Colors.white.withValues(alpha: 0.6),
                                      fontSize: 14)),
                            ],
                          ),
                          const SizedBox(height: 12),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(4),
                            child: LinearProgressIndicator(
                              value: progress,
                              minHeight: 8,
                              backgroundColor:
                                  Colors.white.withValues(alpha: 0.2),
                              valueColor: const AlwaysStoppedAnimation<Color>(
                                  Colors.white),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                  '${(progress * 100).toStringAsFixed(0)}% used — $daysLeft days left',
                                  style: TextStyle(
                                      color:
                                          Colors.white.withValues(alpha: 0.7),
                                      fontSize: 11)),
                              Text(
                                  remaining >= 0
                                      ? 'KES ${remaining.toStringAsFixed(0)} left'
                                      : 'Over by KES ${remaining.abs().toStringAsFixed(0)}',
                                  style: TextStyle(
                                      color: remaining >= 0
                                          ? const Color(0xFFA7F3D0)
                                          : const Color(0xFFFFCDD2),
                                      fontSize: 11,
                                      fontWeight: FontWeight.w600)),
                            ],
                          ),
                        ],
                      ),
              ),

              const SizedBox(height: 12),

              // ── Stat chips ────────────────────────────────────────
              if (total > 0)
                Row(
                  children: [
                    _statChip('Avg / day',
                        'KES ${avgPerDay.toStringAsFixed(0)}', context),
                    const SizedBox(width: 8),
                    _statChip(
                        'Projected',
                        'KES ${projected.toStringAsFixed(0)}',
                        context,
                        valueColor: projected > total
                            ? const Color(0xFFCA8A04)
                            : null),
                    const SizedBox(width: 8),
                    _statChip('Days left', '$daysLeft', context),
                  ],
                ),

              const SizedBox(height: 16),

              // ── Warning card ──────────────────────────────────────
              if (total > 0 && projected > total)
                Container(
                  padding: const EdgeInsets.all(14),
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFFBEB),
                    border: Border.all(color: const Color(0xFFFDE68A)),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(Icons.warning_amber_rounded,
                          color: Color(0xFFCA8A04), size: 18),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Heads up',
                                style: TextStyle(
                                    color: Color(0xFF854F0B),
                                    fontWeight: FontWeight.w600,
                                    fontSize: 13)),
                            const SizedBox(height: 3),
                            Text(
                              'At your current pace you\'ll exceed your budget '
                              'by KES ${(projected - total).toStringAsFixed(0)} this month.',
                              style: const TextStyle(
                                  color: Color(0xFF92400E), fontSize: 12),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

              // ── Category budgets ──────────────────────────────────
              if (expense.categoryBudgets.isNotEmpty) ...[
                Text('Budget by category',
                    style: TextStyle(
                        color: Theme.of(context).colorScheme.onSurface,
                        fontSize: 15,
                        fontWeight: FontWeight.w600)),
                const SizedBox(height: 12),
                Container(
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surface,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    children: expense.categories.where((cat) {
                      return expense.categoryBudgets.containsKey(cat) &&
                          expense.categoryBudgets[cat]! > 0;
                    }).map((cat) {
                      final budget = expense.categoryBudgets[cat] ?? 0;
                      final catSpent = expense.spentForCategory(cat);
                      final catProgress =
                          budget > 0 ? (catSpent / budget).clamp(0.0, 1.0) : 0.0;
                      final catRemaining = budget - catSpent;
                      final isOver = catRemaining < 0;
                      final color = expense.categoryColors[cat] ??
                          const Color(0xFF7C3AED);
                      final icon =
                          expense.categoryIcons[cat] ?? Icons.category;
                      final pct = (catProgress * 100).toStringAsFixed(0);

                      return Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          border: Border(
                            bottom: BorderSide(
                              color: Theme.of(context)
                                  .dividerColor
                                  .withValues(alpha: 0.3),
                            ),
                          ),
                        ),
                        child: Column(
                          children: [
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: color.withValues(alpha: 0.12),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Icon(icon, color: color, size: 16),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Text(cat,
                                      style: TextStyle(
                                          color: Theme.of(context)
                                              .colorScheme
                                              .onSurface,
                                          fontWeight: FontWeight.w600,
                                          fontSize: 13)),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8, vertical: 3),
                                  decoration: BoxDecoration(
                                    color: isOver
                                        ? const Color(0xFFFFEBEE)
                                        : color.withValues(alpha: 0.12),
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Text('$pct%',
                                      style: TextStyle(
                                          color: isOver
                                              ? Colors.red[700]
                                              : color,
                                          fontSize: 11,
                                          fontWeight: FontWeight.w600)),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                    'KES ${catSpent.toStringAsFixed(0)} of ${budget.toStringAsFixed(0)}',
                                    style: TextStyle(
                                        color: Colors.grey[500], fontSize: 11)),
                                Text(
                                    isOver
                                        ? 'Over by KES ${catRemaining.abs().toStringAsFixed(0)}'
                                        : 'KES ${catRemaining.toStringAsFixed(0)} left',
                                    style: TextStyle(
                                        color: isOver
                                            ? Colors.red[600]
                                            : Colors.green[600],
                                        fontSize: 11,
                                        fontWeight: FontWeight.w600)),
                              ],
                            ),
                            const SizedBox(height: 6),
                            ClipRRect(
                              borderRadius: BorderRadius.circular(3),
                              child: LinearProgressIndicator(
                                value: catProgress,
                                minHeight: 6,
                                backgroundColor: Colors.grey[200],
                                valueColor: AlwaysStoppedAnimation<Color>(
                                    isOver ? Colors.red[400]! : color),
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ],

              const SizedBox(height: 24),
            ],
          ),
        );
      }),
    );
  }

  // ── Edit bottom sheet ───────────────────────────────────────────────
  void _showEditBottomSheet(
      BuildContext context, ExpenseController expense, AuthController auth) {
    final overallCtrl = TextEditingController(
        text: expense.totalBudget.value > 0
            ? expense.totalBudget.value.toStringAsFixed(0)
            : '');

    final catCtrls = {
      for (var cat in expense.categories)
        cat: TextEditingController(
            text: (expense.categoryBudgets[cat] ?? 0) > 0
                ? expense.categoryBudgets[cat]!.toStringAsFixed(0)
                : '')
    };

    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Edit budgets',
                      style: TextStyle(
                          fontSize: 18, fontWeight: FontWeight.bold)),
                  IconButton(
                      onPressed: () => Get.back(),
                      icon: const Icon(Icons.close)),
                ],
              ),
              const SizedBox(height: 16),

              // Overall
              const Text('Overall monthly budget',
                  style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey)),
              const SizedBox(height: 8),
              _budgetField(overallCtrl, 'e.g. 30000', context),
              const SizedBox(height: 20),

              const Text('Per category',
                  style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey)),
              const SizedBox(height: 10),

              ...expense.categories.map((cat) {
                final color =
                    expense.categoryColors[cat] ?? const Color(0xFF7C3AED);
                final icon =
                    expense.categoryIcons[cat] ?? Icons.category;
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: color.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(icon, color: color, size: 18),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(cat,
                                style: const TextStyle(
                                    fontSize: 13, fontWeight: FontWeight.w500)),
                            const SizedBox(height: 4),
                            _budgetField(catCtrls[cat]!, 'e.g. 5000', context),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              }),

              const SizedBox(height: 8),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () async {
                    final overall =
                        double.tryParse(overallCtrl.text.trim()) ?? 0;
                    final catBudgets = {
                      for (var cat in expense.categories)
                        cat: double.tryParse(
                                catCtrls[cat]!.text.trim()) ??
                            0
                    };
                    final ok = await expense.saveBudgets(
                        auth.userId.value, overall, catBudgets);
                    if (ok) {
                      Get.back();
                      Get.snackbar('Saved', 'Budgets updated',
                          backgroundColor: const Color(0xFF7C3AED),
                          colorText: Colors.white);
                    } else {
                      Get.snackbar('Error', 'Could not save budgets',
                          backgroundColor: Colors.red[400],
                          colorText: Colors.white);
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF7C3AED),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14)),
                  ),
                  child: const Text('Save budgets',
                      style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16)),
                ),
              ),
              const SizedBox(height: 12),
            ],
          ),
        ),
      ),
      isScrollControlled: true,
    );
  }

  Widget _statChip(String label, String value, BuildContext context,
          {Color? valueColor}) =>
      Expanded(
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label,
                  style:
                      const TextStyle(fontSize: 10, color: Colors.grey)),
              const SizedBox(height: 3),
              Text(value,
                  style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: valueColor ??
                          Theme.of(context).colorScheme.onSurface)),
            ],
          ),
        ),
      );

 Widget _budgetField(
    TextEditingController ctrl,
    String hint,
    BuildContext context,
  ) => TextFormField(
        controller: ctrl,
        keyboardType: TextInputType.number,
        style: TextStyle(fontSize: 14),
        decoration: InputDecoration(
          hintText: hint,
          prefixText: 'KES ',
          prefixStyle:
              const TextStyle(color: Color(0xFF7C3AED), fontWeight: FontWeight.w600),
          filled: true,
          fillColor: Theme.of(context).colorScheme.surface,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide.none,
          ),
        ),
      );

  String _monthName(int month) {
    const names = [
      '', 'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'
    ];
    return names[month];
  }
}