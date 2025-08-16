import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../../../../models/models.dart';
import '../widgets/sales_header.dart';
import '../widgets/sales_list_item.dart';
import '../widgets/sales_empty.dart';
import '../widgets/add_sale_dialog.dart';
import '../widgets/edit_sale_dialog.dart';

class SalesScreen extends StatelessWidget {
  const SalesScreen({super.key});

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
        final sales =
            box.values.where((e) => e.type == 'sale').toList()
              ..sort((a, b) => b.date.compareTo(a.date));

        final totalSales = sales.fold<double>(
          0,
          (sum, sale) => sum + sale.amount,
        );

        return Scaffold(
          body: CustomScrollView(
            slivers: [
              SliverAppBar(
                expandedHeight: 200.0,
                floating: true,
                pinned: true,
                flexibleSpace: FlexibleSpaceBar(
                  background: SalesHeader(
                    totalSales: totalSales,
                    transactions: sales.length,
                  ),
                  title: const Text('Sales'),
                  centerTitle: true,
                ),
              ),
              SliverToBoxAdapter(
                child: sales.isEmpty ? const SalesEmpty() : const SizedBox(),
              ),
              SliverList(
                delegate: SliverChildBuilderDelegate((context, index) {
                  final e = sales[index];
                  final isFirstOfMonth =
                      index == 0 || e.date.month != sales[index - 1].date.month;

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (isFirstOfMonth) ...[
                        Padding(
                          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                          child: Row(
                            children: [
                              Text(
                                _formatMonth(e.date),
                                style: Theme.of(
                                  context,
                                ).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.grey[700],
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Container(
                                  height: 1,
                                  color: Colors.grey[300],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                      SalesListItem(
                        sale: e,
                        formattedDate: _formatDate(e.date),
                        onTap: () => showEditSale(context, e),
                      ),
                    ],
                  );
                }, childCount: sales.length),
              ),
              const SliverPadding(padding: EdgeInsets.only(bottom: 80)),
            ],
          ),
          floatingActionButton: FloatingActionButton.extended(
            onPressed: () => showAddSale(context),
            icon: const Icon(Icons.add),
            label: const Text('Add Sale'),
            backgroundColor: const Color(0xFF4CAF50),
          ),
        );
      },
    );
  }
}
