import 'package:flutter/material.dart';

class MoneyField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  const MoneyField({super.key, required this.controller, this.label = 'Amount'});

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
      ),
      validator: (v) {
        final x = double.tryParse(v ?? '');
        if (x == null || x <= 0) return 'Enter a valid amount';
        return null;
      },
    );
  }
}

class TitleField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  const TitleField({super.key, required this.controller, this.label = 'Title'});

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
      ),
      validator: (v) => (v == null || v.trim().isEmpty) ? 'Required' : null,
    );
  }
}

Future<void> showEntrySavedSnackBar(BuildContext context) async {
  ScaffoldMessenger.of(context)
      .showSnackBar(const SnackBar(content: Text('Saved')));
}
