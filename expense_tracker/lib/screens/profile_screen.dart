import 'package:expense_tracker/controllers/expenses_controllers.dart';
import 'package:expense_tracker/controllers/login_controllers.dart';
import 'package:expense_tracker/controllers/theme_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:fl_chart/fl_chart.dart';  

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = Get.find<AuthController>();
    final expense = Get.find<ExpenseController>();
    final theme = Get.find<ThemeController>();

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0,
        title: Text(
          'Profile',
          style: TextStyle(
            color: Theme.of(context).colorScheme.onSurface,
            fontWeight: FontWeight.bold,
          ),
        ),
        iconTheme: IconThemeData(
          color: Theme.of(context).colorScheme.onSurface,
        ),
      ),
      
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              // ── Avatar & name ──────────────────────────
              Row(
                children: [
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF7C3AED), Color(0xFF4F46E5)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: Center(
                      child: Obx(
                        () => Text(
                          auth.fullName.value.isNotEmpty
                              ? auth.fullName.value[0].toUpperCase()
                              : '?',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Obx(
                        () => Text(
                          auth.fullName.value,
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.onSurface,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Obx(
                        () => Text(
                          '@${auth.username.value}',
                          style: TextStyle(
                            color: Colors.grey[500],
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),

              const SizedBox(height: 20),

              // ── Two-column layout ──────────────────────
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── LEFT: Account info ─────────────────
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.surface,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _sectionTitle('Account Info', context),
                          const SizedBox(height: 10),
                          Obx(
                            () => _infoTile(
                              icon: Icons.person_outline,
                              label: 'Full Name',
                              value: auth.fullName.value,
                              context: context,
                            ),
                          ),
                          _dividerLine(context),
                          Obx(
                            () => _infoTile(
                              icon: Icons.alternate_email,
                              label: 'Username',
                              value: '@${auth.username.value}',
                              context: context,
                            ),
                          ),
                          _dividerLine(context),
                          Obx(
                            () => _infoTile(
                              icon: Icons.email_outlined,
                              label: 'Email',
                              value: auth.email.value,
                              context: context,
                            ),
                          ),
                          _dividerLine(context),
                          Obx(
                            () => _infoTile(
                              icon: Icons.phone_outlined,
                              label: 'Phone',
                              value: auth.phone.value,
                              context: context,
                            ),
                          ),
                          const SizedBox(height: 16),
                          _sectionTitle('Preferences', context),
                          const SizedBox(height: 8),
                          Obx(
                            () => SwitchListTile(
                              contentPadding: EdgeInsets.zero,
                              secondary: Icon(
                                theme.isDarkMode.value
                                    ? Icons.dark_mode_outlined
                                    : Icons.light_mode_outlined,
                                color: const Color(0xFF7C3AED),
                              ),
                              title: Text(
                                'Dark Mode',
                                style: TextStyle(
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.onSurface,
                                  fontWeight: FontWeight.w500,
                                  fontSize: 14,
                                ),
                              ),
                              value: theme.isDarkMode.value,
                              activeThumbColor: const Color(0xFF7C3AED),
                              onChanged: (_) => theme.toggleTheme(),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(width: 12),

                  // ── RIGHT: Stats + Pie chart ───────────
                  Expanded(
                    child: Column(
                      children: [
                        // Stats card
                        Obx(() {
                          final total = expense.totalSpent;
                          final count = expense.expenses.length;
                          final topCat = _topCategory(expense);
                          return Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Theme.of(context).colorScheme.surface,
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _sectionTitle('Spending Summary', context),
                                const SizedBox(height: 10),
                                Row(
                                  children: [
                                    Expanded(
                                      child: _statBox(
                                        'Total Spent',
                                        'KES ${total.toStringAsFixed(0)}',
                                        context,
                                        valueColor: const Color(0xFF7C3AED),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: _statBox(
                                        'Transactions',
                                        '$count',
                                        context,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                _statBox('Top Category', topCat, context),
                              ],
                            ),
                          );
                        }),

                        const SizedBox(height: 12),

                        // Pie chart card
                        Obx(() {
                          final sections = _buildPieSections(expense);
                          return Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Theme.of(context).colorScheme.surface,
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _sectionTitle('By Category', context),
                                const SizedBox(height: 12),
                                Row(
                                  children: [
                                    SizedBox(
                                      height: 120,
                                      width: 120,
                                      child: PieChart(
                                        PieChartData(
                                          sections: sections,
                                          centerSpaceRadius: 30,
                                          sectionsSpace: 2,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: _buildLegend(expense, context),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          );
                        }),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              // ── Logout ─────────────────────────────────
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () => auth.logout(),
                  icon: const Icon(Icons.logout, color: Colors.white),
                  label: const Text(
                    'Log Out',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red[400],
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    
  }

  // ── Helpers ──────────────────────────────────────────────────────────
  Widget _statBox(String label, String value, BuildContext context,
    {Color? valueColor}) =>
  Container(
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
    decoration: BoxDecoration(
      color: Theme.of(context).scaffoldBackgroundColor,
      borderRadius: BorderRadius.circular(10),
    ),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(label, style: TextStyle(color: Colors.grey[500], fontSize: 11)),
      const SizedBox(height: 4),
      Text(value, style: TextStyle(
        color: valueColor ?? Theme.of(context).colorScheme.onSurface,
        fontWeight: FontWeight.bold, fontSize: 15)),
    ]),
  );

static const _catColors = [
  Color(0xFF7C3AED), Color(0xFF4F46E5), Color(0xFF06B6D4),
  Color(0xFFF59E0B), Color(0xFF10B981), Color(0xFFEF4444),
];

List<PieChartSectionData> _buildPieSections(ExpenseController expense) {
  if (expense.expenses.isEmpty) {
    return [PieChartSectionData(value: 1, color: Colors.grey[300]!, title: '')];
  }
  final Map<String, double> totals = {};
  for (final e in expense.expenses) {
    totals[e.category] = (totals[e.category] ?? 0) + e.amount;
  }
  final grandTotal = totals.values.fold(0.0, (a, b) => a + b);
  int i = 0;
  return totals.entries.map((entry) {
    final pct = (entry.value / grandTotal * 100).toStringAsFixed(0);
    return PieChartSectionData(
      value: entry.value,
      color: _catColors[i++ % _catColors.length],
      title: '$pct%',
      titleStyle: const TextStyle(fontSize: 10, color: Colors.white, fontWeight: FontWeight.bold),
      radius: 36,
    );
  }).toList();
}

Widget _buildLegend(ExpenseController expense, BuildContext context) {
  if (expense.expenses.isEmpty) return const SizedBox();
  final Map<String, double> totals = {};
  for (final e in expense.expenses) {
    totals[e.category] = (totals[e.category] ?? 0) + e.amount;
  }
  int i = 0;
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: totals.entries.map((entry) {
      final color = _catColors[i++ % _catColors.length];
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 3),
        child: Row(children: [
          Container(width: 8, height: 8, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
          const SizedBox(width: 6),
          Expanded(child: Text(entry.key,
              style: TextStyle(fontSize: 11, color: Theme.of(context).colorScheme.onSurface),
              overflow: TextOverflow.ellipsis)),
        ]),
      );
    }).toList(),
  );
}
  String _topCategory(ExpenseController expense) {
    if (expense.expenses.isEmpty) return 'None';
    final Map<String, double> totals = {};
    for (final e in expense.expenses) {
      totals[e.category] = (totals[e.category] ?? 0) + e.amount;
    }
    return totals.entries.reduce((a, b) => a.value > b.value ? a : b).key;
  }



  Widget _sectionTitle(String title, BuildContext context) => Align(
    alignment: Alignment.centerLeft,
    child: Text(
      title,
      style: TextStyle(
        color: Theme.of(context).colorScheme.onSurface,
        fontSize: 15,
        fontWeight: FontWeight.w600,
      ),
    ),
  );

  Widget _infoTile({
    required IconData icon,
    required String label,
    required String value,
    required BuildContext context,
  }) => ListTile(
    leading: Icon(icon, color: const Color(0xFF7C3AED), size: 22),
    title: Text(label, style: TextStyle(color: Colors.grey[500], fontSize: 12)),
    subtitle: Text(
      value,
      style: TextStyle(
        color: Theme.of(context).colorScheme.onSurface,
        fontWeight: FontWeight.w500,
        fontSize: 15,
      ),
    ),
  );

  Widget _dividerLine(BuildContext context) => Divider(
    height: 1,
    indent: 56,
    color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.8),
  );
}
