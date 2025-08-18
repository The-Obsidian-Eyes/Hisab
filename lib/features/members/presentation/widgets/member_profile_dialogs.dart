import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:hisab/core/common/models.dart';
import 'package:hisab/core/db/entry.dart';
import 'package:hisab/features/members/domain/entities/member.dart';
import '../../../../core/providers/app_state.dart';
import '../../../../core/common/forms.dart';

Future<void> showAddEquityDialog(BuildContext context, String memberId) async {
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

Future<void> showEditPhoneDialog(BuildContext context, Member member) async {
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

Future<void> showDeleteEquityDialog(
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
                                amount: -deleteAmount,
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
