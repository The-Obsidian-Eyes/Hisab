import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../../../../models/models.dart';
import '../widgets/interest_header.dart';
import '../widgets/interest_list_item.dart';
import '../widgets/interests_empty.dart';
import '../widgets/add_interest_dialog.dart';
import '../widgets/edit_interest_dialog.dart';

class InterestScreen extends StatelessWidget {
  const InterestScreen({super.key});

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
        final interests =
            box.values.where((e) => e.type == 'interest').toList()
              ..sort((a, b) => b.date.compareTo(a.date));

        final totalInterest = interests.fold<double>(
          0,
          (sum, i) => sum + i.amount,
        );

        return Scaffold(
          body: CustomScrollView(
            slivers: [
              SliverAppBar(
                expandedHeight: 200.0,
                floating: true,
                pinned: true,
                flexibleSpace: FlexibleSpaceBar(
                  background: InterestHeader(
                    totalInterest: totalInterest,
                    recordsCount: interests.length,
                  ),
                  title: const Text('Interest'),
                  centerTitle: true,
                ),
              ),
              SliverToBoxAdapter(
                child:
                    interests.isEmpty
                        ? const InterestsEmpty()
                        : const SizedBox(),
              ),
              SliverList(
                delegate: SliverChildBuilderDelegate((context, index) {
                  final e = interests[index];
                  final isFirstOfMonth =
                      index == 0 ||
                      e.date.month != interests[index - 1].date.month;

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (isFirstOfMonth) ...[
                        Padding(
                          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.orange.shade50,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: Colors.orange.shade200),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.calendar_month,
                                  size: 20,
                                  color: Colors.orange[800],
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  _formatMonth(e.date),
                                  style: Theme.of(
                                    context,
                                  ).textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.orange[800],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                      InterestListItem(
                        interest: e,
                        formattedDate: _formatDate(e.date),
                        onTap: () => showEditInterest(context, e),
                      ),
                    ],
                  );
                }, childCount: interests.length),
              ),
              const SliverPadding(padding: EdgeInsets.only(bottom: 80)),
            ],
          ),
          floatingActionButton: FloatingActionButton.extended(
            onPressed: () => showAddInterest(context),
            icon: const Icon(Icons.add),
            label: const Text('Add Interest'),
            backgroundColor: const Color(0xFFFF9800),
          ),
        );
      },
    );
  }
}
