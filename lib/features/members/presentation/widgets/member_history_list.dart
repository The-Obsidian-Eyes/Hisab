import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/providers/app_state.dart';
import 'package:hisab/core/common/models.dart';

class MemberHistoryList extends StatelessWidget {
  final List<Entry> entries;

  const MemberHistoryList({super.key, required this.entries});

  @override
  Widget build(BuildContext context) {
    if (entries.isEmpty) {
      return Center(
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
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(color: Colors.grey[600]),
            ),
            const SizedBox(height: 8),
            Text(
              'Add equity to get started',
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: Colors.grey[500]),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
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
                    color: e.amount >= 0 ? Colors.green : Colors.red,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                // Transaction Details
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            '\$${e.amount.abs().toStringAsFixed(2)}',
                            style: Theme.of(
                              context,
                            ).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: e.amount >= 0 ? Colors.green : Colors.red,
                            ),
                          ),
                          if (e.notes?.isNotEmpty == true) ...[
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                e.notes!,
                                style: Theme.of(context).textTheme.bodyMedium
                                    ?.copyWith(color: Colors.grey[600]),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        e.date.toLocal().toString().split('.')[0],
                        style: Theme.of(
                          context,
                        ).textTheme.bodySmall?.copyWith(color: Colors.grey),
                      ),
                    ],
                  ),
                ),
                // Delete Button
                IconButton(
                  icon: const Icon(Icons.delete_outline, color: Colors.red),
                  style: IconButton.styleFrom(
                    backgroundColor: Colors.red.withOpacity(0.1),
                  ),
                  onPressed: () {
                    showDialog<void>(
                      context: context,
                      builder:
                          (BuildContext ctx) => AlertDialog(
                            title: const Text('Delete History Entry'),
                            content: Text(
                              'Are you sure you want to delete this equity history entry of \$${e.amount.toStringAsFixed(2)}?',
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(ctx),
                                child: const Text('Cancel'),
                              ),
                              FilledButton(
                                onPressed: () {
                                  context.read<AppState>().deleteEntry(e.id);
                                  Navigator.pop(ctx);
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        'History entry of \$${e.amount.toStringAsFixed(2)} was deleted',
                                      ),
                                      backgroundColor: Colors.red,
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
    );
  }
}
