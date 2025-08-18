import 'package:flutter/material.dart';
import 'package:hisab/core/common/models.dart';

class ProfitDistributionConfirmDialog extends StatelessWidget {
  final double amount;
  final List<MapEntry<String, double>> distributions;
  final bool useCustomPercentages;
  final Map<String, String> memberNames; // id -> name map
  final Map<String, double> percentages; // id -> percent map

  const ProfitDistributionConfirmDialog({
    super.key,
    required this.amount,
    required this.distributions,
    required this.useCustomPercentages,
    required this.memberNames,
    required this.percentages,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Confirm Distribution'),
      content: Container(
        width: double.maxFinite,
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.6,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Distribution Summary',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: Colors.blue[700],
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Total Amount: \$${amount.toStringAsFixed(2)}',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 16),
            const Divider(),
            Flexible(
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: distributions.length,
                itemBuilder: (context, index) {
                  final dist = distributions[index];
                  final name = memberNames[dist.key] ?? 'Unknown';
                  final pct = percentages[dist.key] ?? 0.0;
                  return ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(
                      name,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text('${pct.toStringAsFixed(1)}%'),
                    trailing: Text(
                      '\$${dist.value.toStringAsFixed(2)}',
                      style: TextStyle(
                        color: Colors.green[700],
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  );
                },
              ),
            ),
            const Divider(),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.orange[50],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.orange[200]!),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.info_outline, color: Colors.orange[700]),
                      const SizedBox(width: 8),
                      Text(
                        'Important',
                        style: TextStyle(
                          color: Colors.orange[900],
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'This will distribute the profit and start a new season. All transaction history will be cleared, but asset values will be preserved.',
                    style: TextStyle(color: Colors.orange[900]),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: () => Navigator.pop(context, true),
          style: FilledButton.styleFrom(backgroundColor: Colors.green),
          child: const Text('Confirm & Start New Season'),
        ),
      ],
    );
  }
}
