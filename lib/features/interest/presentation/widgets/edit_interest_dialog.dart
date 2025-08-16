import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:hisab/core/common/models.dart';
import 'package:hisab/core/db/entry.dart';

Future<void> showEditInterest(BuildContext context, Entry interest) async {
  final notes = TextEditingController(text: interest.notes);
  final amount = TextEditingController(text: interest.amount.toString());
  final formKey = GlobalKey<FormState>();

  await showDialog<void>(
    context: context,
    builder:
        (BuildContext ctx) => AlertDialog(
          title: const Text('Edit Interest'),
          content: SingleChildScrollView(
            child: Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    controller: notes,
                    decoration: const InputDecoration(
                      labelText: 'Description',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.description),
                    ),
                    validator: (v) => v?.isEmpty ?? true ? 'Required' : null,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: amount,
                    decoration: const InputDecoration(
                      labelText: 'Interest Rate (%)',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.percent),
                      suffixText: '%',
                    ),
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) return 'Required';
                      final rate = double.tryParse(value);
                      if (rate == null) return 'Invalid number';
                      if (rate <= 0) return 'Rate must be positive';
                      if (rate > 100) return 'Rate cannot exceed 100%';
                      return null;
                    },
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
                        title: const Text('Delete Interest Record'),
                        content: const Text(
                          'Are you sure you want to delete this interest record?',
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(deleteCtx),
                            child: const Text('Cancel'),
                          ),
                          FilledButton(
                            onPressed: () {
                              final box = Hive.box<Entry>('entries');
                              box.delete(interest.key);
                              Navigator.pop(deleteCtx);
                              Navigator.pop(ctx);
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Interest record deleted'),
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
                  final rate = double.parse(amount.text);
                  final box = Hive.box<Entry>('entries');
                  final updatedInterest = Entry(
                    id: interest.id,
                    date: DateTime.now(),
                    amount: rate,
                    type: 'interest',
                    notes: notes.text.trim(),
                  );
                  box.put(interest.key, updatedInterest);
                  Navigator.pop(ctx);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Interest record updated successfully'),
                      backgroundColor: Color(0xFFFF9800),
                    ),
                  );
                }
              },
              icon: const Icon(Icons.save),
              label: const Text('Save'),
              style: FilledButton.styleFrom(
                backgroundColor: const Color(0xFFFF9800),
              ),
            ),
          ],
        ),
  );
}
