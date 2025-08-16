import 'package:flutter/material.dart';
import 'stat_card.dart';

class LedgerHeader extends StatelessWidget {
  final double balance;
  final Map<String, double> totals;

  const LedgerHeader({super.key, required this.balance, required this.totals});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF1A237E), Color(0xFF3949AB)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Current Balance',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '\$${balance.toStringAsFixed(2)}',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 36,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 24),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  StatCard(
                    label: 'Sales',
                    amount: totals['sale'] ?? 0,
                    icon: Icons.point_of_sale,
                    color: const Color(0xFF4CAF50),
                  ),
                  StatCard(
                    label: 'Interest',
                    amount: totals['interest'] ?? 0,
                    icon: Icons.percent,
                    color: const Color(0xFFFF9800),
                  ),
                  StatCard(
                    label: 'Equity',
                    amount: totals['equity'] ?? 0,
                    icon: Icons.account_balance_wallet,
                    color: const Color(0xFF2196F3),
                  ),
                  StatCard(
                    label: 'Assets',
                    amount: totals['asset'] ?? 0,
                    icon: Icons.account_balance,
                    color: const Color(0xFF9C27B0),
                  ),
                  StatCard(
                    label: 'Purchases',
                    amount: totals['purchase'] ?? 0,
                    icon: Icons.shopping_cart,
                    color: const Color(0xFFF44336),
                    isNegative: true,
                  ),
                  StatCard(
                    label: 'Expenses',
                    amount: totals['expense'] ?? 0,
                    icon: Icons.money_off,
                    color: const Color(0xFFE91E63),
                    isNegative: true,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
