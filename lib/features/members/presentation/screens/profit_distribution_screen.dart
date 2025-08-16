import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../../../../core/providers/app_state.dart';
import '../../../../models/models.dart';
import '../../../../ui/widgets/forms.dart';

class ProfitDistributionScreen extends StatefulWidget {
  const ProfitDistributionScreen({super.key});

  @override
  State<ProfitDistributionScreen> createState() =>
      _ProfitDistributionScreenState();
}

class _ProfitDistributionScreenState extends State<ProfitDistributionScreen> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final Map<String, TextEditingController> _percentageControllers = {};
  bool _useCustomPercentages = false;

  @override
  void dispose() {
    _amountController.dispose();
    for (final controller in _percentageControllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    final members = appState.members;

    // Initialize controllers for new members
    for (final member in members) {
      if (!_percentageControllers.containsKey(member.id)) {
        final percentage = (appState.memberEquityPercentage(member.id));
        _percentageControllers[member.id] = TextEditingController(
          text: percentage.toStringAsFixed(1),
        );
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Distribute Profit'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF4F8CFF), Color(0xFF6FE7FF)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFE3F0FF), Color(0xFFF8FBFF)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Card(
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
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
                          controller: _amountController,
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
                            Switch(
                              value: _useCustomPercentages,
                              onChanged: (value) {
                                setState(() {
                                  _useCustomPercentages = value;
                                  if (!value) {
                                    // Reset to equity percentages
                                    for (final member in members) {
                                      final percentage = appState
                                          .memberEquityPercentage(member.id);
                                      _percentageControllers[member.id]?.text =
                                          percentage.toStringAsFixed(1);
                                    }
                                  }
                                });
                              },
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 80),
                  itemCount: members.length,
                  itemBuilder: (context, index) {
                    final member = members[index];
                    final equityPercentage = appState.memberEquityPercentage(
                      member.id,
                    );

                    return Card(
                      elevation: 0,
                      margin: const EdgeInsets.only(bottom: 8),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    member.name,
                                    style:
                                        Theme.of(context).textTheme.titleMedium,
                                  ),
                                  if (!_useCustomPercentages) ...[
                                    const SizedBox(height: 4),
                                    Text(
                                      'Based on equity: ${equityPercentage.toStringAsFixed(1)}%',
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodySmall
                                          ?.copyWith(color: Colors.grey[600]),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                            if (_useCustomPercentages)
                              SizedBox(
                                width: 80,
                                child: TextFormField(
                                  controller: _percentageControllers[member.id],
                                  decoration: const InputDecoration(
                                    suffixText: '%',
                                    isDense: true,
                                  ),
                                  keyboardType:
                                      const TextInputType.numberWithOptions(
                                        decimal: true,
                                      ),
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Required';
                                    }
                                    final percentage = double.tryParse(value);
                                    if (percentage == null) {
                                      return 'Invalid';
                                    }
                                    if (percentage < 0 || percentage > 100) {
                                      return 'Invalid';
                                    }
                                    return null;
                                  },
                                ),
                              ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          if (!_formKey.currentState!.validate()) return;

          final amount = double.tryParse(_amountController.text);
          if (amount == null || amount <= 0) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Please enter a valid amount')),
            );
            return;
          }

          if (_useCustomPercentages) {
            // Validate total percentage is 100%
            final total = _percentageControllers.values
                .map((c) => double.tryParse(c.text) ?? 0)
                .fold<double>(0, (sum, p) => sum + p);

            if ((total - 100).abs() > 0.1) {
              // Allow small rounding errors
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Total percentage must equal 100%'),
                  backgroundColor: Colors.red,
                ),
              );
              return;
            }
          }

          // Calculate distributions
          final distributions = <MapEntry<String, double>>[];
          for (final member in members) {
            final percentage =
                _useCustomPercentages
                    ? double.parse(_percentageControllers[member.id]!.text)
                    : appState.memberEquityPercentage(member.id);

            final share = amount * (percentage / 100);
            distributions.add(MapEntry(member.id, share));
          }

          // Show confirmation dialog
          final result = await showDialog<bool>(
            context: context,
            builder:
                (context) => AlertDialog(
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
                          style: Theme.of(
                            context,
                          ).textTheme.titleLarge?.copyWith(
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
                              final member = members.firstWhere(
                                (m) => m.id == dist.key,
                              );
                              final percentage =
                                  _useCustomPercentages
                                      ? double.parse(
                                        _percentageControllers[member.id]!.text,
                                      )
                                      : appState.memberEquityPercentage(
                                        member.id,
                                      );

                              return ListTile(
                                contentPadding: EdgeInsets.zero,
                                title: Text(
                                  member.name,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                subtitle: Text(
                                  '${percentage.toStringAsFixed(1)}%',
                                ),
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
                                  Icon(
                                    Icons.info_outline,
                                    color: Colors.orange[700],
                                  ),
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
                      style: FilledButton.styleFrom(
                        backgroundColor: Colors.green,
                      ),
                      child: const Text('Confirm & Start New Season'),
                    ),
                  ],
                ),
          );

          if (result == true && context.mounted) {
            try {
              // 1. Store current effective equities
              final memberEquities =
                  appState.members
                      .map(
                        (member) => MapEntry(
                          member.id,
                          appState.memberEffectiveEquity(member.id),
                        ),
                      )
                      .toList();

              // 2. Delete non-equity, non-asset entries
              final box = Hive.box<Entry>('entries');
              final entriesToDelete =
                  box.values
                      .where((e) => e.type != 'equity' && e.type != 'asset')
                      .map((e) => e.key)
                      .whereType<dynamic>()
                      .toList();
              await box.deleteAll(entriesToDelete);

              // Delete old equity entries
              final oldEquityEntries =
                  box.values
                      .where((e) => e.type == 'equity')
                      .map((e) => e.key)
                      .whereType<dynamic>()
                      .toList();
              await box.deleteAll(oldEquityEntries);

              // 3. Create profit distribution entries and update base equities
              for (final dist in distributions) {
                final finalEquity =
                    memberEquities.firstWhere((e) => e.key == dist.key).value;

                // Update member's base equity
                await appState.updateMemberEquity(dist.key, finalEquity);

                // Create a new equity entry
                final entry = Entry(
                  id: DateTime.now().microsecondsSinceEpoch.toString(),
                  date: DateTime.now(),
                  amount: finalEquity,
                  type: 'equity',
                  memberId: dist.key,
                  notes:
                      'Season End: Profit Distribution (\$${dist.value.toStringAsFixed(2)})',
                );
                await box.put(entry.id, entry);
              }

              if (context.mounted) {
                Navigator.pop(context); // Close the screen
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Profit distributed and new season started'),
                    backgroundColor: Colors.green,
                  ),
                );
              }
            } catch (e) {
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Error: $e'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            }
          }
        },
        icon: const Icon(Icons.calculate_outlined),
        label: const Text('Calculate Distribution'),
        backgroundColor: Colors.blue,
      ),
    );
  }
}
