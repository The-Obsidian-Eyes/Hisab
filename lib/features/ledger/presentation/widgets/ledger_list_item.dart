import 'package:flutter/material.dart';
import '../../../../models/models.dart';
import 'ledger_helpers.dart';
import 'transaction_detail_dialog.dart';

class LedgerListItem extends StatelessWidget {
  final Entry entry;
  final String formattedDate;

  const LedgerListItem({
    super.key,
    required this.entry,
    required this.formattedDate,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => showTransactionDetails(context, entry),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: getTypeColor(entry.type).withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                getTypeIcon(entry.type),
                color: getTypeColor(entry.type),
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    entry.type.toUpperCase(),
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: getTypeColor(entry.type),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    entry.notes ?? 'No description',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  Text(
                    entry.date.toLocal().toString().split('.')[0],
                    style: Theme.of(
                      context,
                    ).textTheme.bodySmall?.copyWith(color: Colors.grey[600]),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            Text(
              formatAmount(entry.amount, entry.type),
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: getTypeColor(entry.type),
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
