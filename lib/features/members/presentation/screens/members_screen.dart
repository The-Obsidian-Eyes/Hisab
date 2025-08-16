import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../../../../core/providers/app_state.dart';
import '../../../../models/models.dart';
import '../widgets/member_tile.dart';
import 'profit_distribution_screen.dart';

class MembersScreen extends StatelessWidget {
  const MembersScreen({super.key});

  Future<void> _showResetSeasonDialog(BuildContext context) async {
    final box = Hive.box<Entry>('entries');
    final nonEquityEntries = box.values.where((e) => e.type != 'equity');
    final expenses = box.values.where((e) => e.type == 'expense');
    final sales = box.values.where((e) => e.type == 'sale');
    final purchases = box.values.where((e) => e.type == 'purchase');
    final interest = box.values.where((e) => e.type == 'interest');

    final result = await showDialog<bool>(
      context: context,
      builder:
          (ctx) => AlertDialog(
            title: const Text('Reset Season'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('This will:', style: Theme.of(ctx).textTheme.bodyLarge),
                const SizedBox(height: 8),
                Text(
                  '• Set base equity equal to effective equity for all members\n'
                  '• Clear:\n'
                  '  - ${expenses.length} expenses\n'
                  '  - ${sales.length} sales\n'
                  '  - ${purchases.length} purchases\n'
                  '  - ${interest.length} interest entries\n'
                  '\nNOTE: Asset values will be preserved.',
                  style: Theme.of(ctx).textTheme.bodyMedium,
                ),
                const SizedBox(height: 16),
                Text(
                  'This action cannot be undone.',
                  style: Theme.of(ctx).textTheme.bodyMedium?.copyWith(
                    color: Colors.red,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx, false),
                child: const Text('Cancel'),
              ),
              FilledButton(
                onPressed: () => Navigator.pop(ctx, true),
                style: FilledButton.styleFrom(backgroundColor: Colors.red),
                child: const Text('Reset Season'),
              ),
            ],
          ),
    );

    if (result == true && context.mounted) {
      try {
        final appState = context.read<AppState>();

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

        // 3. Update base equities and create new equity entries
        for (final memberEquity in memberEquities) {
          // Update member's base equity
          await appState.updateMemberEquity(
            memberEquity.key,
            memberEquity.value,
          );

          // Create a new equity entry for the final amount
          final entry = Entry(
            id: DateTime.now().microsecondsSinceEpoch.toString(),
            date: DateTime.now(),
            amount: memberEquity.value,
            type: 'equity',
            memberId: memberEquity.key,
            notes: 'Season reset: Base equity adjusted',
          );
          await box.put(entry.id, entry);
        }

        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Season reset complete: History cleared and member equities updated',
              ),
              backgroundColor: Colors.green,
            ),
          );
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error resetting season: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  void _showAddMember(BuildContext context) {
    final name = TextEditingController();
    final phone = TextEditingController();
    final formKey = GlobalKey<FormState>();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      showDragHandle: true,
      builder:
          (ctx) => Container(
            padding: EdgeInsets.only(
              left: 16,
              right: 16,
              bottom: MediaQuery.of(ctx).viewInsets.bottom + 16,
            ),
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(ctx).size.height * 0.8,
            ),
            child: SingleChildScrollView(
              child: Form(
                key: formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      'Add New Member',
                      style: Theme.of(ctx).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: name,
                      decoration: const InputDecoration(
                        labelText: 'Name',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter a name';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: phone,
                      decoration: const InputDecoration(
                        labelText: 'Phone (optional)',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.phone,
                    ),
                    const SizedBox(height: 16),
                    FilledButton(
                      onPressed: () {
                        if (formKey.currentState!.validate()) {
                          final memberName = name.text.trim();
                          final memberPhone = phone.text.trim();
                          context.read<AppState>().addMember(
                            memberName,
                            phone: memberPhone,
                          );
                          Navigator.pop(ctx);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('${name.text.trim()} was added'),
                            ),
                          );
                        }
                      },
                      child: const Text('Save'),
                    ),
                  ],
                ),
              ),
            ),
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final s = context.watch<AppState>();

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text('Members & Equity'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const ProfitDistributionScreen(),
                ),
              );
            },
            icon: const Icon(Icons.savings),
            tooltip: 'Distribute Profit',
          ),
          IconButton(
            onPressed: () => _showResetSeasonDialog(context),
            icon: const Icon(Icons.refresh_rounded),
            tooltip: 'Reset Season',
          ),
        ],
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
        child: Column(
          children: [
            const SizedBox(height: kToolbarHeight + 16),
            // Summary Card
            Padding(
              padding: const EdgeInsets.all(16),
              child: Card(
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                color: Colors.white,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Total Members',
                                style: Theme.of(context).textTheme.titleMedium,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '${s.members.length}',
                                style: Theme.of(
                                  context,
                                ).textTheme.headlineSmall?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.indigo,
                                ),
                              ),
                            ],
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                'Total Base Equity',
                                style: Theme.of(context).textTheme.titleMedium,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '\$${s.totalBaseEquity.toStringAsFixed(2)}',
                                style: Theme.of(
                                  context,
                                ).textTheme.headlineSmall?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.blue,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
            // Members List
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 80),
                itemCount: s.members.length,
                itemBuilder: (context, index) {
                  final m = s.members[index];
                  return MemberTile(m: m);
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddMember(context),
        label: const Text('Add Member'),
        icon: const Icon(Icons.person_add),
        backgroundColor: Colors.indigo,
      ),
    );
  }
}
