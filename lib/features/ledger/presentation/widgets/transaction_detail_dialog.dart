import 'package:flutter/material.dart';
import 'package:hisab/core/common/models.dart';
import 'package:hisab/core/db/entry.dart';
import 'ledger_helpers.dart';
import 'detail_row.dart';

void showTransactionDetails(BuildContext context, Entry entry) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    builder:
        (ctx) => Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: getTypeColor(entry.type).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      getTypeIcon(entry.type),
                      color: getTypeColor(entry.type),
                      size: 32,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          entry.type.toUpperCase(),
                          style: Theme.of(
                            context,
                          ).textTheme.titleSmall?.copyWith(
                            color: getTypeColor(entry.type),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          formatAmount(entry.amount, entry.type),
                          style: Theme.of(
                            context,
                          ).textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: getTypeColor(entry.type),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              DetailRow(
                icon: Icons.description_outlined,
                label: 'Description',
                value: entry.notes ?? 'No description',
              ),
              const SizedBox(height: 16),
              DetailRow(
                icon: Icons.calendar_today,
                label: 'Date & Time',
                value: entry.date.toLocal().toString().split('.')[0],
              ),
              const SizedBox(height: 16),
              DetailRow(
                icon: Icons.tag,
                label: 'Transaction ID',
                value: entry.id,
                isMonospace: true,
              ),
              if (entry.memberId != null) ...[
                const SizedBox(height: 16),
                DetailRow(
                  icon: Icons.person_outline,
                  label: 'Member ID',
                  value: entry.memberId!,
                  isMonospace: true,
                ),
              ],
            ],
          ),
        ),
  );
}
