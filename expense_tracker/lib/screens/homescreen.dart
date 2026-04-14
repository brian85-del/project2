import 'package:expense_tracker/controllers/expenses_controllers.dart';
import 'package:expense_tracker/controllers/login_controllers.dart';
import 'package:expense_tracker/controllers/theme_controller.dart';
import 'package:expense_tracker/screens/budget_screen.dart';
import 'package:expense_tracker/screens/profile_screen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'add_expense_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final expense = Get.find<ExpenseController>();
    final theme = Get.find<ThemeController>();
    final auth = Get.find<AuthController>();

    return Scaffold(
      drawer: Drawer(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        child: SafeArea(
          child: Column(
            children: [
              Obx(
                () => UserAccountsDrawerHeader(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Color(0xFF7C3AED), Color(0xFF4F46E5)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                  accountName: Text(
                    auth.fullName.value,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  accountEmail: Text(auth.email.value),
                  currentAccountPicture: CircleAvatar(
                    backgroundColor: Colors.white,
                    child: Text(
                      auth.fullName.value.isNotEmpty
                          ? auth.fullName.value[0].toUpperCase()
                          : '?',
                      style: const TextStyle(
                        fontSize: 24,
                        color: Color(0xFF7C3AED),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
              _drawerItem(
                context,
                icon: Icons.home_outlined,
                label: 'Home',
                onTap: () => Get.back(),
              ),
              _drawerItem(
                context,
                icon: Icons.person_outline,
                label: 'Profile',
                onTap: () {
                  Get.back();
                  Get.to(() => const ProfileScreen());
                },
              ),
              _drawerItem(
                context,
                icon: Icons.add_circle_outline,
                label: 'Add Expense',
                onTap: () {
                  Get.back();
                  Get.to(() => AddExpenseScreen());
                },
              ),
              Obx(
                () => _drawerItem(
                  context,
                  icon: theme.isDarkMode.value
                      ? Icons.light_mode_outlined
                      : Icons.dark_mode_outlined,
                  label: theme.isDarkMode.value ? 'Light Mode' : 'Dark Mode',
                  onTap: () {
                    Get.back();
                    theme.toggleTheme();
                  },
                ),
              ),
              const Spacer(),
              const Divider(),
              _drawerItem(
                context,
                icon: Icons.logout,
                label: 'Log Out',
                color: Colors.red[400]!,
                onTap: () => auth.logout(),
              ),
              const SizedBox(height: 12),
            ],
          ),
        ),
      ),

      body: SafeArea(
        child: Column(
          children: [
            // ── Header ─────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Builder(
                    builder: (ctx) => GestureDetector(
                      onTap: () => Scaffold.of(ctx).openDrawer(),
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.surface,
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Icon(
                          Icons.menu,
                          color: Theme.of(context).colorScheme.onSurface,
                          size: 20,
                        ),
                      ),
                    ),
                  ),
                  Obx(
                    () => Column(
                      children: [
                        Text(
                          'Welcome back,',
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.onSurface,
                            fontSize: 14,
                          ),
                        ),
                        Text(
                          auth.fullName.value,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                          ),
                        ),
                      ],
                    ),
                  ),
                  GestureDetector(
                    onTap: () => Get.to(() => AddExpenseScreen()),
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFF7C3AED),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: const Icon(
                        Icons.add,
                        color: Colors.white,
                        size: 22,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ── Total card with mini stats ──────────────────
                    Obx(() {
                      final total = expense.totalSpent;
                      final count = expense.expenses.length;
                      final now = DateTime.now();
                      final weekAgo = now.subtract(const Duration(days: 7));
                      final weekTotal = expense.expenses
                          .where((e) => e.date.isAfter(weekAgo))
                          .fold(0.0, (sum, e) => sum + e.amount);
                      final daysInMonth = DateUtils.getDaysInMonth(
                        now.year,
                        now.month,
                      );
                      final daysPassed = now.day;
                      final avgPerDay = daysPassed > 0
                          ? total / daysPassed
                          : 0.0;

                      return Container(
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
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Total spent this month',
                              style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.8),
                                fontSize: 13,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              'KES ${total.toStringAsFixed(0)}',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 30,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 14),
                            Row(
                              children: [
                                _miniStat(
                                  'This week',
                                  'KES ${weekTotal.toStringAsFixed(0)}',
                                ),
                                const SizedBox(width: 8),
                                _miniStat(
                                  'Avg / day',
                                  'KES ${avgPerDay.toStringAsFixed(0)}',
                                ),
                                const SizedBox(width: 8),
                                _miniStat('Transactions', '$count'),
                              ],
                            ),
                          ],
                        ),
                      );
                    }),

                    const SizedBox(height: 16),

                    // ── Quick actions ───────────────────────────────
                    Row(
                      children: [
                        _quickAction(
                          context,
                          icon: Icons.add_circle_outline,
                          label: 'Add',
                          color: const Color(0xFF7C3AED),
                          bg: const Color(0xFFEDE9FE),
                          onTap: () => Get.to(() => AddExpenseScreen()),
                        ),
                        const SizedBox(width: 10),
                        _quickAction(
                          context,
                          icon: Icons.person_outline,
                          label: 'Profile',
                          color: const Color(0xFF0284C7),
                          bg: const Color(0xFFE0F2FE),
                          onTap: () => Get.to(() => const ProfileScreen()),
                        ),
                        const SizedBox(width: 10),
                        _quickAction(
                          context,
                          icon: Icons.bar_chart_outlined,
                          label: 'Reports',
                          color: const Color(0xFF16A34A),
                          bg: const Color(0xFFDCFCE7),
                          onTap: () {}, // hook up when ready
                        ),
                        const SizedBox(width: 10),
                       _quickAction(
                          context,
                          icon: Icons.savings_outlined,
                          label: 'Budget',
                          color: const Color(0xFFCA8A04),
                          bg: const Color(0xFFFEF9C3),
                          onTap: () => Get.to(() => const BudgetScreen()),
                        ),
                      ],
                    ),

                    const SizedBox(height: 16),

                    // ── Budget progress ─────────────────────────────
                    Obx(() {
                      const budget = 30000.0; // hardcoded for now
                      final spent = expense.totalSpent;
                      final progress = (spent / budget).clamp(0.0, 1.0);
                      final remaining = budget - spent;
                      final now = DateTime.now();
                      final daysLeft =
                          DateUtils.getDaysInMonth(now.year, now.month) -
                          now.day;

                      return Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.surface,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Monthly budget',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: Colors.grey,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'KES ${spent.toStringAsFixed(0)} of ${budget.toStringAsFixed(0)}',
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.onSurface,
                                  ),
                                ),
                                Text(
                                  'KES ${remaining.toStringAsFixed(0)} left',
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                    color: remaining < 0
                                        ? Colors.red[400]
                                        : Colors.green[600],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            ClipRRect(
                              borderRadius: BorderRadius.circular(4),
                              child: LinearProgressIndicator(
                                value: progress,
                                minHeight: 8,
                                backgroundColor: Colors.grey[200],
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  progress > 0.9
                                      ? Colors.red[400]!
                                      : const Color(0xFF7C3AED),
                                ),
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              '${(progress * 100).toStringAsFixed(0)}% used — $daysLeft days remaining',
                              style: TextStyle(
                                fontSize: 11,
                                color: Colors.grey[500],
                              ),
                            ),
                          ],
                        ),
                      );
                    }),

                    const SizedBox(height: 16),

                    // ── Spending by category ────────────────────────
                    Obx(() {
                      if (expense.expenses.isEmpty) return const SizedBox();

                      final Map<String, double> totals = {};
                      for (final e in expense.expenses) {
                        totals[e.category] =
                            (totals[e.category] ?? 0) + e.amount;
                      }
                      final maxVal = totals.values.reduce(
                        (a, b) => a > b ? a : b,
                      );
                      final sorted = totals.entries.toList()
                        ..sort((a, b) => b.value.compareTo(a.value));

                      return Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.surface,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Spending by category',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: Colors.grey,
                              ),
                            ),
                            const SizedBox(height: 12),
                            ...sorted.map((entry) {
                              final color =
                                  expense.categoryColors[entry.key] ??
                                  const Color(0xFF7C3AED);
                              final pct = entry.value / maxVal;
                              return Padding(
                                padding: const EdgeInsets.only(bottom: 10),
                                child: Row(
                                  children: [
                                    SizedBox(
                                      width: 72,
                                      child: Text(
                                        entry.key,
                                        style: TextStyle(
                                          fontSize: 11,
                                          color: Colors.grey[500],
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(3),
                                        child: LinearProgressIndicator(
                                          value: pct,
                                          minHeight: 6,
                                          backgroundColor: Colors.grey[200],
                                          valueColor:
                                              AlwaysStoppedAnimation<Color>(
                                                color,
                                              ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    SizedBox(
                                      width: 64,
                                      child: Text(
                                        'KES ${entry.value.toStringAsFixed(0)}',
                                        textAlign: TextAlign.right,
                                        style: TextStyle(
                                          fontSize: 11,
                                          fontWeight: FontWeight.w600,
                                          color: Theme.of(
                                            context,
                                          ).colorScheme.onSurface,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            }),
                          ],
                        ),
                      );
                    }),

                    const SizedBox(height: 16),

                    // ── Recent transactions (last 5) ────────────────
                    Obx(() {
                      if (expense.expenses.isEmpty) {
                        return Center(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 40),
                            child: Column(
                              children: [
                                Icon(
                                  Icons.receipt_long,
                                  size: 60,
                                  color: Colors.grey[700],
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  'No expenses yet',
                                  style: TextStyle(
                                    color: Colors.grey[600],
                                    fontSize: 16,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Tap + to add your first one',
                                  style: TextStyle(
                                    color: Colors.grey[700],
                                    fontSize: 13,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      }

                      final recent = expense.expenses.reversed.take(5).toList();

                      return Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.surface,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text(
                                  'Recent transactions',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.grey,
                                  ),
                                ),
                                GestureDetector(
                                  onTap: () {}, // link to full list screen
                                  child: const Text(
                                    'See all',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Color(0xFF7C3AED),
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            ...recent.map((e) {
                              final color =
                                  expense.categoryColors[e.category] ??
                                  const Color(0xFFA8A8B3);
                              final icon =
                                  expense.categoryIcons[e.category] ??
                                  Icons.category;
                              return Padding(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 6,
                                ),
                                child: Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(8),
                                      decoration: BoxDecoration(
                                        color: color.withValues(alpha: 0.15),
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      child: Icon(icon, color: color, size: 18),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            e.title,
                                            style: TextStyle(
                                              color: Theme.of(
                                                context,
                                              ).colorScheme.onSurface,
                                              fontWeight: FontWeight.w600,
                                              fontSize: 13,
                                            ),
                                          ),
                                          Text(
                                            '${e.category} • ${e.date.day}/${e.date.month}/${e.date.year}',
                                            style: TextStyle(
                                              color: Colors.grey[500],
                                              fontSize: 11,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Text(
                                      'KES ${e.amount.toStringAsFixed(0)}',
                                      style: TextStyle(
                                        color: color,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 13,
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            }),
                          ],
                        ),
                      );
                    }),

                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Mini stat chip inside total card ─────────────────────────────
  Widget _miniStat(String label, String value) => Expanded(
    child: Container(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 10),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(color: Colors.white70, fontSize: 10),
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
        ],
      ),
    ),
  );

  // ── Quick action button ───────────────────────────────────────────
  Widget _quickAction(
    BuildContext context, {
    required IconData icon,
    required String label,
    required Color color,
    required Color bg,
    required VoidCallback onTap,
  }) => Expanded(
    child: GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: bg,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: color, size: 18),
            ),
            const SizedBox(height: 6),
            Text(
              label,
              style: TextStyle(fontSize: 10, color: Colors.grey[500]),
            ),
          ],
        ),
      ),
    ),
  );

  // ── Drawer item ───────────────────────────────────────────────────
  Widget _drawerItem(
    BuildContext context, {
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    Color? color,
  }) => ListTile(
    leading: Icon(icon, color: color ?? const Color(0xFF7C3AED), size: 22),
    title: Text(
      label,
      style: TextStyle(
        color: color ?? Theme.of(context).colorScheme.onSurface,
        fontWeight: FontWeight.w500,
      ),
    ),
    onTap: onTap,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
    horizontalTitleGap: 8,
  );
}
