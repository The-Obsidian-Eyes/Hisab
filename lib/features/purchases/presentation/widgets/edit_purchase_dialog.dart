import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../../../../models/models.dart';
import '../../../../ui/widgets/forms.dart';

Future<void> showEditPurchase(BuildContext context, Entry purchase) async {
  final notes = TextEditingController(text: purchase.notes);
  final amount = TextEditingController(text: purchase.amount.toString());
  final formKey = GlobalKey<FormState>();

  await showDialog<void>(
    context: context,
    builder:
        (BuildContext ctx) => AlertDialog(
          title: const Text('Edit Purchase'),
          content: SingleChildScrollView(
            child: Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  MoneyField(controller: amount, label: 'Amount'),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: notes,
                    decoration: const InputDecoration(
                      labelText: 'Notes',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.notes),
                    ),
                    minLines: 1,
                    maxLines: 3,
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel'),
            ),
            TextButton.icon(
              onPressed: () {
                showDialog<void>(
                  context: context,
                  builder:
                      (BuildContext deleteCtx) => AlertDialog(
                        title: const Text('Delete Purchase'),
                        content: const Text(
                          'Are you sure you want to delete this purchase?',
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(deleteCtx),
                            child: const Text('Cancel'),
                          ),
                          FilledButton(
                            onPressed: () {
                              final box = Hive.box<Entry>('entries');
                              box.delete(purchase.key);
                              Navigator.pop(deleteCtx);
                              Navigator.pop(ctx);
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Purchase deleted'),
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
              icon: const Icon(Icons.delete_outline, color: Colors.red),
              label: const Text('Delete', style: TextStyle(color: Colors.red)),
            ),
            FilledButton.icon(
              onPressed: () {
                if (formKey.currentState!.validate()) {
                  final amt = double.parse(amount.text);
                  final box = Hive.box<Entry>('entries');
                  final updatedPurchase = Entry(
                    id: purchase.id,
                    date: DateTime.now(),
                    amount: amt,
                    type: 'purchase',
                    notes: notes.text.trim(),
                  );
                  box.put(purchase.key, updatedPurchase);
                  Navigator.pop(ctx);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Purchase updated successfully'),
                      backgroundColor: Color(0xFF2196F3),
                    ),
                  );
                }
              },
              icon: const Icon(Icons.save),
              label: const Text('Save'),
              style: FilledButton.styleFrom(
                backgroundColor: const Color(0xFF2196F3),
              ),
            ),
          ],
        ),
  );
}
