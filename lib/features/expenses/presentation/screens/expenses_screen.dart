import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../../../../models/models.dart';
import '../widgets/expenses_header.dart';
import '../widgets/expenses_list_item.dart';
import '../widgets/expenses_empty.dart';
import '../widgets/add_expense_dialog.dart';
import '../widgets/edit_expense_dialog.dart';

class ExpensesScreen extends StatelessWidget {
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

  Future<void> _showAddExpense(BuildContext context) async {
    await showAddExpense(context);
  }

  Future<void> _showEditExpense(BuildContext context, Entry expense) async {
    await showEditExpense(context, expense);
  }

  const ExpensesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: Hive.box<Entry>('entries').listenable(),
      builder: (context, box, _) {
        final expenses =
            box.values.where((e) => e.type == 'expense').toList()
              ..sort((a, b) => b.date.compareTo(a.date));

        final totalExpenses = expenses.fold<double>(
          0,
          (sum, expense) => sum + expense.amount,
        );

        return Scaffold(
          body: CustomScrollView(
            slivers: [
              SliverAppBar(
                expandedHeight: 200.0,
                floating: true,
                pinned: true,
                flexibleSpace: FlexibleSpaceBar(
                  background: ExpensesHeader(totalExpenses: totalExpenses),
                  title: const Text('Expenses'),
                  centerTitle: true,
                ),
              ),
              SliverToBoxAdapter(
                child:
                    expenses.isEmpty ? const ExpensesEmpty() : const SizedBox(),
              ),
              SliverList(
                delegate: SliverChildBuilderDelegate((context, index) {
                  final e = expenses[index];
                  final isFirstOfMonth =
                      index == 0 ||
                      e.date.month != expenses[index - 1].date.month;

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (isFirstOfMonth)
                        Padding(
                          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                          child: Text(
                            _formatMonth(e.date),
                            style: Theme.of(
                              context,
                            ).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: Colors.grey[700],
                            ),
                          ),
                        ),
                      ExpensesListItem(
                        expense: e,
                        formattedDate: _formatDate(e.date),
                        onTap: () => _showEditExpense(context, e),
                      ),
                    ],
                  );
                }, childCount: expenses.length),
              ),
              const SliverPadding(padding: EdgeInsets.only(bottom: 80)),
            ],
          ),
          floatingActionButton: FloatingActionButton.extended(
            onPressed: () => _showAddExpense(context),
            icon: const Icon(Icons.add),
            label: const Text('Add Expense'),
            backgroundColor: const Color(0xFFFF6B6B),
          ),
        );
      },
    );
  }
}
