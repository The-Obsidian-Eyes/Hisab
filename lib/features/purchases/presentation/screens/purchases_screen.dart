import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../../../../models/models.dart';
// ...existing code...
import '../widgets/purchase_header.dart';
import '../widgets/purchase_list_item.dart';
import '../widgets/purchases_empty.dart';
import '../widgets/add_purchase_dialog.dart';
import '../widgets/edit_purchase_dialog.dart';

class PurchasesScreen extends StatelessWidget {
  const PurchasesScreen({super.key});

  String _formatMonth(DateTime date) {
    final months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];
    return '${months[date.month - 1]} ${date.year}';
  }

  String _formatDate(DateTime date) {
    return '${date.day} ${_formatMonth(date).substring(0, 3)}';
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: Hive.box<Entry>('entries').listenable(),
      builder: (context, box, _) {
        final purchases =
            box.values.where((e) => e.type == 'purchase').toList()
              ..sort((a, b) => b.date.compareTo(a.date));

        final totalPurchases = purchases.fold<double>(
          0,
          (sum, purchase) => sum + purchase.amount,
        );

        return Scaffold(
          body: CustomScrollView(
            slivers: [
              SliverAppBar(
                expandedHeight: 200.0,
                floating: true,
                pinned: true,
                flexibleSpace: FlexibleSpaceBar(
                  background: PurchaseHeader(
                    totalPurchases: totalPurchases,
                    purchasesCount: purchases.length,
                  ),
                  title: const Text('Purchases'),
                  centerTitle: true,
                ),
              ),
              SliverToBoxAdapter(
                child:
                    purchases.isEmpty
                        ? const PurchasesEmpty()
                        : const SizedBox(),
              ),
              SliverList(
                delegate: SliverChildBuilderDelegate((context, index) {
                  final e = purchases[index];
                  final isFirstOfMonth =
                      index == 0 ||
                      e.date.month != purchases[index - 1].date.month;

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (isFirstOfMonth) ...[
                        Padding(
                          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFF2196F3).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(
                                  Icons.calendar_today,
                                  size: 16,
                                  color: Color(0xFF2196F3),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  _formatMonth(e.date),
                                  style: Theme.of(
                                    context,
                                  ).textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: const Color(0xFF2196F3),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                      PurchaseListItem(
                        purchase: e,
                        formattedDate: _formatDate(e.date),
                        onTap: () => showEditPurchase(context, e),
                      ),
                    ],
                  );
                }, childCount: purchases.length),
              ),
              const SliverPadding(padding: EdgeInsets.only(bottom: 80)),
            ],
          ),
          floatingActionButton: FloatingActionButton.extended(
            onPressed: () => showAddPurchase(context),
            icon: const Icon(Icons.add),
            label: const Text('Add Purchase'),
            backgroundColor: const Color(0xFF2196F3),
          ),
        );
      },
    );
  }
}
