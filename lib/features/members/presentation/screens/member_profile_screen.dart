import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../models/models.dart';
import '../../../../core/providers/app_state.dart';
import '../../../../ui/widgets/forms.dart';

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final Color color;
  final IconData icon;

  const _StatCard({
    required this.title,
    required this.value,
    required this.color,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(
            title,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

class MemberProfileScreen extends StatelessWidget {
  final String memberId;

  const MemberProfileScreen({super.key, required this.memberId});

  @override
  Widget build(BuildContext context) {
    final s = context.watch<AppState>();
    final member = s.members.firstWhere((m) => m.id == memberId);
    final entries =
        s.entries
            .where((e) => e.type == 'equity' && e.memberId == memberId)
            .toList()
          ..sort((a, b) => b.date.compareTo(a.date));
    final totalEquity = s.totalEquity;
    final equity = s.memberEquity(memberId);
    final percentage = totalEquity > 0 ? (equity / totalEquity * 100) : 0.0;

    return Scaffold(
      appBar: AppBar(
        title: Text(member.name),
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
        child: Column(
          children: [
            // Profile Card
            Padding(
              padding: const EdgeInsets.all(16),
              child: Card(
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    children: [
                      CircleAvatar(
                        radius: 48,
                        backgroundColor: Colors.indigo.shade50,
                        child: Text(
                          member.name[0].toUpperCase(),
                          style: const TextStyle(
                            fontSize: 32,
                            color: Colors.indigo,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        member.name,
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            member.phone.isEmpty
                                ? 'No phone number'
                                : member.phone,
                            style: Theme.of(context).textTheme.bodyMedium
                                ?.copyWith(color: Colors.grey),
                          ),
                          const SizedBox(width: 8),
                          IconButton(
                            onPressed: () => _showEditPhone(context, member),
                            icon: const Icon(Icons.edit),
                            iconSize: 16,
                            style: IconButton.styleFrom(
                              padding: const EdgeInsets.all(4),
                              backgroundColor: Colors.grey[100],
                            ),
                            tooltip: 'Edit phone number',
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      // Stats Row
                      Wrap(
                        spacing: 12,
                        runSpacing: 12,
                        alignment: WrapAlignment.center,
                        children: [
                          _StatCard(
                            title: 'Base Equity',
                            value:
                                '\$${s.memberBaseEquity(memberId).toStringAsFixed(2)}',
                            color: Colors.blue,
                            icon: Icons.account_balance_wallet,
                          ),
                          _StatCard(
                            title: 'Effective Equity',
                            value:
                                '\$${s.memberEffectiveEquity(memberId).toStringAsFixed(2)}',
                            color: Colors.green,
                            icon: Icons.trending_up,
                          ),
                          _StatCard(
                            title: 'Share Percentage',
                            value:
                                '${s.memberEquityPercentage(memberId).toStringAsFixed(1)}%',
                            color: Colors.indigo,
                            icon: Icons.pie_chart,
                          ),
                          if (s.totalProfitLoss != 0)
                            _StatCard(
                              title: 'Profit/Loss Share',
                              value:
                                  '\$${(s.totalProfitLoss * (s.memberBaseEquity(memberId) / s.totalBaseEquity)).toStringAsFixed(2)}',
                              color:
                                  s.totalProfitLoss > 0
                                      ? Colors.green
                                      : Colors.red,
                              icon:
                                  s.totalProfitLoss > 0
                                      ? Icons.arrow_upward
                                      : Icons.arrow_downward,
                            ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      // Action Buttons
                      Row(
                        children: [
                          Expanded(
                            child: FilledButton.icon(
                              onPressed:
                                  () => _showAddEquity(context, memberId),
                              icon: const Icon(Icons.add),
                              label: const Text('Add Equity'),
                              style: FilledButton.styleFrom(
                                backgroundColor: Colors.indigo,
                                minimumSize: const Size(double.infinity, 45),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: FilledButton.icon(
                              onPressed:
                                  () => _showDeleteEquity(context, entries),
                              icon: const Icon(Icons.remove),
                              label: const Text('Delete Equity'),
                              style: FilledButton.styleFrom(
                                backgroundColor: Colors.red,
                                minimumSize: const Size(double.infinity, 45),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
            // History Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  Icon(Icons.history, color: Colors.grey[700], size: 20),
                  const SizedBox(width: 8),
                  Text(
                    'Transaction History',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[800],
                    ),
                  ),
                  const Spacer(),
                  Text(
                    '${entries.length} entries',
                    style: Theme.of(
                      context,
                    ).textTheme.bodySmall?.copyWith(color: Colors.grey[600]),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            // Transaction List
            Expanded(
              child:
                  entries.isEmpty
                      ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.account_balance_wallet_outlined,
                              size: 64,
                              color: Colors.grey[400],
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'No transactions yet',
                              style: Theme.of(context).textTheme.titleMedium
                                  ?.copyWith(color: Colors.grey[600]),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Add equity to get started',
                              style: Theme.of(context).textTheme.bodyMedium
                                  ?.copyWith(color: Colors.grey[500]),
                            ),
                          ],
                        ),
                      )
                      : ListView.builder(
                        padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                        itemCount: entries.length,
                        itemBuilder: (context, index) {
                          final e = entries[index];
                          return Card(
                            margin: const EdgeInsets.only(bottom: 8),
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(12),
                              child: Row(
                                children: [
                                  // Transaction Icon
                                  Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color:
                                          e.amount >= 0
                                              ? Colors.green.withOpacity(0.1)
                                              : Colors.red.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Icon(
                                      e.amount >= 0 ? Icons.add : Icons.remove,
                                      color:
                                          e.amount >= 0
                                              ? Colors.green
                                              : Colors.red,
                                      size: 20,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  // Transaction Details
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            Text(
                                              '\$${e.amount.abs().toStringAsFixed(2)}',
                                              style: Theme.of(
                                                context,
                                              ).textTheme.titleMedium?.copyWith(
                                                fontWeight: FontWeight.bold,
                                                color:
                                                    e.amount >= 0
                                                        ? Colors.green
                                                        : Colors.red,
                                              ),
                                            ),
                                            if (e.notes?.isNotEmpty ==
                                                true) ...[
                                              const SizedBox(width: 8),
                                              Expanded(
                                                child: Text(
                                                  e.notes!,
                                                  style: Theme.of(context)
                                                      .textTheme
                                                      .bodyMedium
                                                      ?.copyWith(
                                                        color: Colors.grey[600],
                                                      ),
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                ),
                                              ),
                                            ],
                                          ],
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          e.date.toLocal().toString().split(
                                            '.',
                                          )[0],
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodySmall
                                              ?.copyWith(color: Colors.grey),
                                        ),
                                      ],
                                    ),
                                  ),
                                  // Delete Button
                                  IconButton(
                                    icon: const Icon(
                                      Icons.delete_outline,
                                      color: Colors.red,
                                    ),
                                    style: IconButton.styleFrom(
                                      backgroundColor: Colors.red.withOpacity(
                                        0.1,
                                      ),
                                    ),
                                    onPressed: () {
                                      showDialog<void>(
                                        context: context,
                                        builder:
                                            (BuildContext ctx) => AlertDialog(
                                              title: const Text(
                                                'Delete History Entry',
                                              ),
                                              content: Text(
                                                'Are you sure you want to delete this equity history entry of \$${e.amount.toStringAsFixed(2)}?',
                                              ),
                                              actions: [
                                                TextButton(
                                                  onPressed:
                                                      () => Navigator.pop(ctx),
                                                  child: const Text('Cancel'),
                                                ),
                                                FilledButton(
                                                  onPressed: () {
                                                    context
                                                        .read<AppState>()
                                                        .deleteEntry(e.id);
                                                    Navigator.pop(ctx);
                                                    ScaffoldMessenger.of(
                                                      context,
                                                    ).showSnackBar(
                                                      SnackBar(
                                                        content: Text(
                                                          'History entry of \$${e.amount.toStringAsFixed(2)} was deleted',
                                                        ),
                                                        backgroundColor:
                                                            Colors.red,
                                                      ),
                                                    );
                                                  },
                                                  style: FilledButton.styleFrom(
                                                    backgroundColor: Colors.red,
                                                  ),
                                                  child: const Text('Delete'),
                                                ),
                                              ],
                                            ),
                                      );
                                    },
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
    );
  }
}

Future<void> _showAddEquity(BuildContext context, String memberId) async {
  final amount = TextEditingController();
  final notes = TextEditingController();
  final formKey = GlobalKey<FormState>();

  await showModalBottomSheet(
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
                  Text('Add Equity', style: Theme.of(ctx).textTheme.titleLarge),
                  const SizedBox(height: 12),
                  MoneyField(controller: amount, label: 'Amount'),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: notes,
                    decoration: const InputDecoration(
                      labelText: 'Notes',
                      border: OutlineInputBorder(),
                    ),
                    minLines: 1,
                    maxLines: 3,
                  ),
                  const SizedBox(height: 16),
                  FilledButton(
                    onPressed: () {
                      if (formKey.currentState!.validate()) {
                        final amt = double.parse(amount.text);
                        context.read<AppState>().addEntry(
                          Entry.equity(
                            memberId: memberId,
                            amount: amt,
                            notes: notes.text.trim(),
                          ),
                        );
                        Navigator.pop(ctx);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Equity added successfully'),
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

Future<void> _showEditPhone(BuildContext context, Member member) async {
  final phoneController = TextEditingController(text: member.phone);
  final formKey = GlobalKey<FormState>();

  await showDialog<void>(
    context: context,
    builder:
        (BuildContext ctx) => AlertDialog(
          title: const Text('Edit Phone Number'),
          content: Form(
            key: formKey,
            child: TextFormField(
              controller: phoneController,
              decoration: const InputDecoration(
                labelText: 'Phone Number',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.phone),
              ),
              keyboardType: TextInputType.phone,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return null; // Phone number is optional
                }
                // Add your phone number validation logic here if needed
                return null;
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel'),
            ),
            FilledButton.icon(
              onPressed: () {
                if (formKey.currentState!.validate()) {
                  context.read<AppState>().updateMemberPhone(
                    member.id,
                    phoneController.text.trim(),
                  );
                  Navigator.pop(ctx);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Phone number updated successfully'),
                    ),
                  );
                }
              },
              icon: const Icon(Icons.save),
              label: const Text('Save'),
            ),
          ],
        ),
  );
}

Future<void> _showDeleteEquity(
  BuildContext context,
  List<Entry> entries,
) async {
  final amount = TextEditingController();
  final notes = TextEditingController();
  final formKey = GlobalKey<FormState>();
  final totalAmount = entries.fold<double>(0, (sum, e) => sum + e.amount);
  final screenSize = MediaQuery.of(context).size;

  return showDialog<void>(
    context: context,
    builder:
        (BuildContext context) => Dialog(
          child: Container(
            width: screenSize.width * 0.9,
            constraints: BoxConstraints(
              maxWidth: 400,
              maxHeight: screenSize.height * 0.8,
            ),
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Delete Equity',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 16),
                Flexible(
                  child: SingleChildScrollView(
                    child: Form(
                      key: formKey,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'How much equity would you like to delete?',
                            style: Theme.of(context).textTheme.bodyLarge,
                          ),
                          const SizedBox(height: 16),
                          TextFormField(
                            controller: amount,
                            decoration: const InputDecoration(
                              labelText: 'Amount to Delete',
                              border: OutlineInputBorder(),
                              prefixIcon: Icon(Icons.attach_money),
                            ),
                            keyboardType: const TextInputType.numberWithOptions(
                              decimal: true,
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter an amount';
                              }
                              final amt = double.tryParse(value);
                              if (amt == null) {
                                return 'Please enter a valid number';
                              }
                              if (amt <= 0) {
                                return 'Amount must be greater than zero';
                              }
                              if (amt > totalAmount) {
                                return 'Cannot delete more than total equity (\$${totalAmount.toStringAsFixed(2)})';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 12),
                          TextFormField(
                            controller: notes,
                            decoration: const InputDecoration(
                              labelText: 'Notes',
                              border: OutlineInputBorder(),
                            ),
                            minLines: 1,
                            maxLines: 3,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Total equity: \$${totalAmount.toStringAsFixed(2)}',
                            style: TextStyle(color: Colors.grey.shade600),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Cancel'),
                    ),
                    const SizedBox(width: 8),
                    FilledButton(
                      onPressed: () {
                        if (formKey.currentState!.validate()) {
                          final deleteAmount = double.parse(amount.text);
                          final entry = entries.first;
                          if (entry.memberId != null) {
                            context.read<AppState>().addEntry(
                              Entry.equity(
                                memberId: entry.memberId!,
                                amount:
                                    -deleteAmount, // Negative amount to subtract equity
                                notes: notes.text.trim(),
                              ),
                            );
                          }
                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                'Deleted \$${deleteAmount.toStringAsFixed(2)} from equity',
                              ),
                              backgroundColor: Colors.red,
                            ),
                          );
                        }
                      },
                      style: FilledButton.styleFrom(
                        backgroundColor: Colors.red,
                      ),
                      child: const Text('Delete'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
  );
}
