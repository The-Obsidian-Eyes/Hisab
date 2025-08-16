import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../../../../models/models.dart';
import '../widgets/ledger_header.dart';
import '../widgets/ledger_list_item.dart';
import '../widgets/ledger_empty.dart';
import '../widgets/date_group_header.dart';
import '../widgets/ledger_helpers.dart';

class LedgerScreen extends StatelessWidget {
  const LedgerScreen({super.key});

  // date formatting helpers moved to ledger_helpers.dart

  // ...helpers moved to widgets/ledger_helpers.dart

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: Hive.box<Entry>('entries').listenable(),
      builder: (context, box, _) {
        final entries =
            box.values.toList()..sort((a, b) => b.date.compareTo(a.date));

        final totals = entries.fold<Map<String, double>>({}, (map, e) {
          map[e.type] = (map[e.type] ?? 0) + e.amount;
          return map;
        });

        final balance =
            (totals['sale'] ?? 0) +
            (totals['interest'] ?? 0) +
            (totals['equity'] ?? 0) +
            (totals['asset'] ?? 0) -
            (totals['purchase'] ?? 0) -
            (totals['expense'] ?? 0);

        return Scaffold(
          body: CustomScrollView(
            slivers: [
              SliverAppBar(
                expandedHeight: 280.0,
                floating: false,
                pinned: true,
                flexibleSpace: FlexibleSpaceBar(
                  background: LedgerHeader(balance: balance, totals: totals),
                  title: const Text('Ledger'),
                  centerTitle: true,
                ),
              ),
              SliverToBoxAdapter(
                child: entries.isEmpty ? const LedgerEmpty() : const SizedBox(),
              ),
              SliverList(
                delegate: SliverChildBuilderDelegate((context, index) {
                  final e = entries[index];
                  final isFirstOfDay =
                      index == 0 ||
                      e.date.day != entries[index - 1].date.day ||
                      e.date.month != entries[index - 1].date.month;

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (isFirstOfDay) ...[
                        DateGroupHeader(formattedDate: formatDateShort(e.date)),
                      ],
                      LedgerListItem(
                        entry: e,
                        formattedDate: formatDateShort(e.date),
                      ),
                      if (index < entries.length - 1)
                        Padding(
                          padding: const EdgeInsets.only(left: 64),
                          child: Container(height: 1, color: Colors.grey[200]),
                        ),
                    ],
                  );
                }, childCount: entries.length),
              ),
            ],
          ),
        );
      },
    );
  }
}

// ...existing code...
