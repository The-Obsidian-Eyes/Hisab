import 'package:flutter/material.dart';
import './stat_pill.dart';

class InterestHeader extends StatelessWidget {
  final double totalInterest;
  final int recordsCount;

  const InterestHeader({
    super.key,
    required this.totalInterest,
    required this.recordsCount,
  });

  @override
  Widget build(BuildContext context) {
    final avgRate = recordsCount > 0 ? (totalInterest / recordsCount) : 0.0;
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFFFF9800), Color(0xFFFFB74D)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Total Interest',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '\$${totalInterest.toStringAsFixed(2)}',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 36,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                StatPill(
                  icon: Icons.show_chart,
                  label: 'Avg Rate',
                  value: '${avgRate.toStringAsFixed(1)}%',
                ),
                const SizedBox(width: 12),
                StatPill(
                  icon: Icons.receipt_long,
                  label: 'Records',
                  value: recordsCount.toString(),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
