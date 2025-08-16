import 'package:hive/hive.dart';

part 'entry.g.dart';

@HiveType(typeId: 1)
class Entry extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final DateTime date;

  @HiveField(2)
  final double amount;

  @HiveField(3)
  final String type;

  @HiveField(4)
  final String? memberId;

  @HiveField(5)
  final String? notes;

  Entry({
    required this.id,
    required this.date,
    required this.amount,
    required this.type,
    this.memberId,
    this.notes,
  });

  Entry.equity({
    required String memberId,
    required double amount,
    String? notes,
  }) : this(
         id: DateTime.now().microsecondsSinceEpoch.toString(),
         date: DateTime.now(),
         amount: amount,
         type: 'equity',
         memberId: memberId,
         notes: notes,
       );
}
