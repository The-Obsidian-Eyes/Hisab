import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../../../../../core/providers/app_state.dart';
import 'package:hisab/core/db/entry.dart';
import '../../../../core/common/forms.dart';
import 'profit_distribution_row.dart';
import 'profit_distribution_confirm_dialog.dart';
import 'profit_distribution_form.dart';
import 'profit_distribution_list.dart';

class ProfitDistributionView extends StatefulWidget {
  const ProfitDistributionView({super.key});

  @override
  State<ProfitDistributionView> createState() => _ProfitDistributionViewState();
}

class _ProfitDistributionViewState extends State<ProfitDistributionView> {
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
              ProfitDistributionForm(
                amountController: _amountController,
                useCustom: _useCustomPercentages,
                onUseCustomChanged: (value) {
                  setState(() {
                    _useCustomPercentages = value;
                    if (!value) {
                      for (final member in members) {
                        final percentage = appState.memberEquityPercentage(
                          member.id,
                        );
                        _percentageControllers[member.id]?.text = percentage
                            .toStringAsFixed(1);
                      }
                    }
                  });
                },
                members: members,
                percentageControllers: _percentageControllers,
              ),
              Expanded(
                child: ProfitDistributionList(
                  members: members,
                  percentageControllers: _percentageControllers,
                  useCustom: _useCustomPercentages,
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
          // Build a name map and percentage map for the confirmation dialog
          final memberNames = {for (var m in members) m.id: m.name};
          final percentageMap = <String, double>{};
          for (final m in members) {
            percentageMap[m.id] =
                _useCustomPercentages
                    ? double.tryParse(_percentageControllers[m.id]!.text) ?? 0.0
                    : appState.memberEquityPercentage(m.id) * 100;
          }

          final result = await showDialog<bool>(
            context: context,
            builder:
                (context) => ProfitDistributionConfirmDialog(
                  amount: amount,
                  distributions: distributions,
                  useCustomPercentages: _useCustomPercentages,
                  memberNames: memberNames,
                  percentages: percentageMap,
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

              // 2.a Create a cash entry representing the profit payout so the
              // dashboard cash balance decreases by the distributed amount.
              // We add this after deletion so it won't be removed by the reset
              // deletion logic above.
              final payoutEntry = Entry(
                id: 'profit_payout_${DateTime.now().microsecondsSinceEpoch}',
                date: DateTime.now(),
                amount: -amount, // negative to subtract cash
                type: 'cash',
                notes: 'Profit distribution payout',
              );
              await box.put(payoutEntry.id, payoutEntry);

              // After adding the payout entry, adjust the cash position so the
              // total cash equals -totalAssets (same invariant used in
              // resetSeason). We compute the current cash sum and add a
              // delta entry if needed.
              final currentCashSum = box.values
                  .where((e) => e.type == 'cash')
                  .fold<double>(0.0, (s, e) => s + e.amount);
              final totalAssets = box.values
                  .where((e) => e.type == 'asset')
                  .fold<double>(0.0, (s, e) => s + e.amount);
              final desiredCashSum = -totalAssets;
              final delta = desiredCashSum - currentCashSum;
              if ((delta).abs() > 0.0001) {
                final adjustEntry = Entry(
                  id:
                      'season_cash_adjust_${DateTime.now().microsecondsSinceEpoch}',
                  date: DateTime.now(),
                  amount: delta,
                  type: 'cash',
                  notes: 'Season cash adjustment',
                );
                await box.put(adjustEntry.id, adjustEntry);
              }

              // 3. Create profit distribution entries and update base equities
              for (final dist in distributions) {
                // Snapshot equity before distribution
                final snapshotEquity =
                    memberEquities.firstWhere((e) => e.key == dist.key).value;

                // Adjust equity by subtracting the distributed payout share so
                // the member's base equity for the new season reflects the
                // post-payout position.
                final adjustedEquity = snapshotEquity - dist.value;

                // Update member's base equity to the adjusted (post-payout)
                // value.
                await appState.updateMemberEquity(dist.key, adjustedEquity);

                // Create a new equity entry reflecting the new base equity.
                final entry = Entry(
                  id: DateTime.now().microsecondsSinceEpoch.toString(),
                  date: DateTime.now(),
                  amount: adjustedEquity,
                  type: 'equity',
                  memberId: dist.key,
                  notes:
                      'Season End: Base Equity after distribution (payout: \$${dist.value.toStringAsFixed(2)})',
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
