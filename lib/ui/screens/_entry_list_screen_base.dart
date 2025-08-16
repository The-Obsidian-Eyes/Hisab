import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/providers/app_state.dart';
import '../../models/models.dart';
import '../widgets/forms.dart';

typedef EntryBuilder =
    Entry Function({
      required String title,
      required double amount,
      String? notes,
    });

class EntryListScreenBase extends StatelessWidget {
  final String title;
  final String type;
  final EntryBuilder builder;
  final IconData icon;

  const EntryListScreenBase({
    super.key,
    required this.title,
    required this.type,
    required this.builder,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final s = context.watch<AppState>();
    final items =
        s.entries.where((e) => e.type == type).toList()
          ..sort((a, b) => b.date.compareTo(a.date));

    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: ListView.builder(
        itemCount: items.length,
        itemBuilder: (ctx, i) {
          final e = items[i];
          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: ListTile(
              leading: Icon(icon),
              title: Text(e.notes ?? ''),
              subtitle: Text(
                '${e.amount.toStringAsFixed(2)} · ${e.date.toLocal().toString().split('.').first}',
              ),
              trailing: IconButton(
                icon: const Icon(Icons.delete_outline),
                onPressed: () => context.read<AppState>().deleteEntry(e.id),
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddGeneric(context, title, builder),
        label: const Text('Add'),
        icon: const Icon(Icons.add),
      ),
    );
  }
}

Future<void> _showAddGeneric(
  BuildContext context,
  String title,
  EntryBuilder builder,
) async {
  final t = TextEditingController();
  final a = TextEditingController();
  final n = TextEditingController();
  final key = GlobalKey<FormState>();

  await showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    builder:
        (ctx) => Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(ctx).viewInsets.bottom,
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Form(
              key: key,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('Add $title', style: Theme.of(ctx).textTheme.titleLarge),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: t,
                    decoration: InputDecoration(
                      labelText: '$title Description',
                      border: const OutlineInputBorder(),
                    ),
                    validator: (v) => (v?.isEmpty ?? true) ? 'Required' : null,
                  ),
                  const SizedBox(height: 12),
                  MoneyField(controller: a),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: n,
                    decoration: const InputDecoration(
                      labelText: 'Notes (Optional)',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 12),
                  FilledButton(
                    onPressed: () {
                      if (key.currentState!.validate()) {
                        final amt = double.parse(a.text);
                        final entry = builder(
                          title: t.text.trim(),
                          amount: amt,
                          notes: n.text.trim(),
                        );
                        context.read<AppState>().addEntry(entry);
                        Navigator.pop(ctx);
                        showEntrySavedSnackBar(context);
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
