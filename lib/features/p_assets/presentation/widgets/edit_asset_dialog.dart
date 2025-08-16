import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';
import '../../../../core/providers/app_state.dart';
import 'package:hisab/core/common/models.dart';
import 'package:hisab/core/db/entry.dart';
import '../../../../core/common/forms.dart';

Future<void> showEditAsset(BuildContext context, Entry asset) async {
  final notes = TextEditingController(text: asset.notes);
  final amount = TextEditingController(text: asset.amount.toString());
  final formKey = GlobalKey<FormState>();

  await showDialog<void>(
    context: context,
    builder:
        (BuildContext ctx) => AlertDialog(
          title: const Text('Edit Asset'),
          content: SingleChildScrollView(
            child: Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
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
                        title: const Text('Delete Asset'),
                        content: const Text(
                          'Are you sure you want to delete this asset?',
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(deleteCtx),
                            child: const Text('Cancel'),
                          ),
                          FilledButton(
                            onPressed: () async {
                              final appState = Provider.of<AppState>(
                                context,
                                listen: false,
                              );

                              final double amt = asset.amount;

                              final purchaseEntry = Entry(
                                id:
                                    '${DateTime.now().microsecondsSinceEpoch}_purchase',
                                date: DateTime.now(),
                                amount: amt,
                                type: 'purchase',
                                notes: 'Asset deleted: ${asset.notes ?? ''}',
                              );

                              final cashAdjustEntry = Entry(
                                id:
                                    '${DateTime.now().microsecondsSinceEpoch}_cash_adj',
                                date: DateTime.now(),
                                amount: amt,
                                type: 'cash',
                                notes:
                                    'Cash adjust for asset deletion: ${asset.notes ?? ''}',
                              );

                              await appState.addEntry(purchaseEntry);
                              await appState.addEntry(cashAdjustEntry);

                              // delete asset
                              await appState.deleteEntry(asset.id);

                              Navigator.pop(deleteCtx);
                              Navigator.pop(ctx);
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Asset deleted'),
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

                  // calculate totals to ensure non-negative
                  final box = Hive.box<Entry>('entries');
                  final assets = box.values.where(
                    (e) => e.type == 'asset' && e.id != asset.id,
                  );
                  final totalOtherAssets = assets.fold<double>(
                    0,
                    (sum, asset) => sum + asset.amount,
                  );
                  final newTotal = totalOtherAssets + amt;
                  if (newTotal < 0) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                          'Cannot update asset: Would result in negative total assets',
                        ),
                        backgroundColor: Colors.red,
                      ),
                    );
                    return;
                  }

                  final updatedAsset = Entry(
                    id: asset.id,
                    date: DateTime.now(),
                    amount: amt,
                    type: 'asset',
                    notes: notes.text.trim(),
                  );
                  await appState.addEntry(updatedAsset);
                  Navigator.pop(ctx);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Asset updated successfully'),
                      backgroundColor: Color(0xFF9C27B0),
                    ),
                  );
                }
              },
              icon: const Icon(Icons.save),
              label: const Text('Save'),
              style: FilledButton.styleFrom(
                backgroundColor: const Color(0xFF9C27B0),
              ),
            ),
          ],
        ),
  );
}
