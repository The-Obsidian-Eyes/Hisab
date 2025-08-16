import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/providers/app_state.dart';
import '../../../../models/stat_info.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen>
    with SingleTickerProviderStateMixin {
  @override
  Widget build(BuildContext context) {
    final s = context.watch<AppState>();

    final stats = [
      StatInfo(
        'Cash Balance',
        s.cashBalance,
        Icons.account_balance,
        Colors.green,
      ),
      StatInfo('Total Equity', s.totalEquity, Icons.trending_up, Colors.blue),
      StatInfo(
        'Net Profit',
        s.netProfit,
        Icons.show_chart,
        s.netProfit >= 0 ? Colors.green : Colors.red,
      ),
      StatInfo(
        'ROI',
        s.roi,
        Icons.percent,
        s.roi >= 0 ? Colors.green : Colors.red,
        showPercentage: true,
      ),
      StatInfo(
        'Gross Profit',
        s.grossProfit,
        Icons.analytics,
        Colors.deepPurple,
      ),
      StatInfo('Assets Value', s.totalAssets, Icons.pie_chart, Colors.orange),
      StatInfo('Sales', s.totalSales, Icons.shopping_cart, Colors.purple),
      StatInfo('Purchases', s.totalPurchases, Icons.shopping_bag, Colors.teal),
      StatInfo('Expenses', s.totalExpenses, Icons.money_off, Colors.red),
      StatInfo('Interest', s.totalInterest, Icons.percent, Colors.indigo),
    ];

    final wide = MediaQuery.of(context).size.width > 600;

    return Scaffold(
      extendBodyBehindAppBar: true,
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFE3F0FF), Color(0xFFF8FBFF)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: GridView.count(
          padding: const EdgeInsets.all(16),
          crossAxisCount: wide ? 3 : 2,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          children: stats.map((s) => _StatCard(s)).toList(),
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final StatInfo stat;
  const _StatCard(this.stat);

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Card(
      elevation: 0,
      color: scheme.surfaceContainerHigh,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: stat.color,
                  radius: 16,
                  child: Icon(stat.icon, color: Colors.white, size: 20),
                ),
                const SizedBox(width: 10),
                Text(
                  stat.title,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              stat.formattedValue,
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: stat.color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
