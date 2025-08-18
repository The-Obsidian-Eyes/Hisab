import 'package:flutter/material.dart';
import 'package:hisab/core/common/models.dart';

class ProfitDistributionRow extends StatelessWidget {
  final Member member;
  final double equityPercentage;
  final double value;
  final bool useCustom;
  final TextEditingController? percentageController;

  const ProfitDistributionRow({
    super.key,
    required this.member,
    required this.equityPercentage,
    required this.value,
    required this.useCustom,
    this.percentageController,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            CircleAvatar(
              radius: 20,
              backgroundColor: Colors.indigo.shade50,
              child: Text(
                member.name.isNotEmpty ? member.name[0].toUpperCase() : '?',
                style: const TextStyle(color: Colors.indigo),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    member.name,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    '\$${value.toStringAsFixed(2)} • ${equityPercentage.toStringAsFixed(1)}%',
                    style: Theme.of(
                      context,
                    ).textTheme.bodySmall?.copyWith(color: Colors.grey[700]),
                  ),
                ],
              ),
            ),
            if (useCustom)
              SizedBox(
                width: 88,
                child: TextFormField(
                  controller: percentageController,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  decoration: const InputDecoration(
                    suffixText: '%',
                    isDense: true,
                    border: OutlineInputBorder(),
                  ),
                  validator: (v) {
                    final d = double.tryParse(v ?? '');
                    if (d == null || d < 0 || d > 100) return '0-100';
                    return null;
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }
}
