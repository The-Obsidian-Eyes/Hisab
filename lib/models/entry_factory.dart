import 'entry.dart';

// Helper functions to create entries
Entry expense({required String title, required double amount, String? notes}) =>
    Entry(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      date: DateTime.now(),
      amount: amount,
      type: 'expense',
      notes: notes != null ? '$title: $notes' : title,
    );

Entry sale({required String title, required double amount, String? notes}) =>
    Entry(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      date: DateTime.now(),
      amount: amount,
      type: 'sale',
      notes: notes != null ? '$title: $notes' : title,
    );

Entry purchase({
  required String title,
  required double amount,
  String? notes,
}) => Entry(
  id: DateTime.now().millisecondsSinceEpoch.toString(),
  date: DateTime.now(),
  amount: amount,
  type: 'purchase',
  notes: notes != null ? '$title: $notes' : title,
);

Entry asset({required String title, required double amount, String? notes}) =>
    Entry(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      date: DateTime.now(),
      amount: amount,
      type: 'asset',
      notes: notes != null ? '$title: $notes' : title,
    );

Entry interest({
  required String title,
  required double amount,
  String? notes,
}) => Entry(
  id: DateTime.now().millisecondsSinceEpoch.toString(),
  date: DateTime.now(),
  amount: amount,
  type: 'interest',
  notes: notes != null ? '$title: $notes' : title,
);

Entry equity({
  required String memberId,
  required double amount,
  String? notes,
}) => Entry(
  id: DateTime.now().millisecondsSinceEpoch.toString(),
  date: DateTime.now(),
  amount: amount,
  type: 'equity',
  memberId: memberId,
  notes: notes,
);
