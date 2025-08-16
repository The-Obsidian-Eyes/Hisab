import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/providers/app_state.dart';
import 'package:hisab/core/common/models.dart';
import 'package:hisab/core/db/entry.dart';
import '../../../../core/common/forms.dart';

Future<void> showAddAsset(BuildContext context) async {
  final notes = TextEditingController();
  final amount = TextEditingController();
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
                  Text('Add Asset', style: Theme.of(ctx).textTheme.titleLarge),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: notes,
                    decoration: const InputDecoration(
                      labelText: 'Asset Description',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.description),
                    ),
                    validator: (v) => v?.isEmpty ?? true ? 'Required' : null,
                  ),
                  const SizedBox(height: 12),
                  MoneyField(controller: amount, label: 'Value'),
                  const SizedBox(height: 16),
                  FilledButton.icon(
                    onPressed: () async {
                      if (formKey.currentState!.validate()) {
                        final amt = double.parse(amount.text);
                        if (amt <= 0) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Asset value must be positive'),
                              backgroundColor: Colors.red,
                            ),
                          );
                          return;
                        }

                        final appState = Provider.of<AppState>(
                          context,
                          listen: false,
                        );

                        final cashEntry = Entry(
                          id: '${DateTime.now().microsecondsSinceEpoch}_cash',
                          date: DateTime.now(),
                          amount: -amt,
                          type: 'cash',
                          notes: 'Cash used for asset: ${notes.text.trim()}',
                        );

                        final assetEntry = Entry(
                          id: DateTime.now().microsecondsSinceEpoch.toString(),
                          date: DateTime.now(),
                          amount: amt,
                          type: 'asset',
                          notes: notes.text.trim(),
                        );

                        await appState.addEntry(cashEntry);
                        await appState.addEntry(assetEntry);
                        Navigator.pop(ctx);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Asset added successfully'),
                            backgroundColor: Color(0xFF9C27B0),
                          ),
                        );
                      }
                    },
                    icon: const Icon(Icons.save),
                    label: const Text('Save'),
                    style: FilledButton.styleFrom(
                      backgroundColor: const Color(0xFF9C27B0),
                      minimumSize: const Size(double.infinity, 48),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
  );
}
