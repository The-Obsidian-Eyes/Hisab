import 'package:flutter/material.dart';
import 'package:hisab/core/common/models.dart';
import '../../../../core/common/forms.dart';

class ProfitDistributionForm extends StatelessWidget {
  final TextEditingController amountController;
  final bool useCustom;
  final ValueChanged<bool> onUseCustomChanged;
  final List<Member> members;
  final Map<String, TextEditingController> percentageControllers;

  const ProfitDistributionForm({
    super.key,
    required this.amountController,
    required this.useCustom,
    required this.onUseCustomChanged,
    required this.members,
    required this.percentageControllers,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Card(
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Enter Profit Amount',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 12),
              MoneyField(
                controller: amountController,
                label: 'Amount to Distribute',
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Text(
                    'Custom Distribution',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const Spacer(),
                  Switch(value: useCustom, onChanged: onUseCustomChanged),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
