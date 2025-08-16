import 'package:hive/hive.dart';

part 'member.g.dart';

@HiveType(typeId: 0)
class Member extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String name;

  @HiveField(2)
  final String phone;

  @HiveField(3)
  final double baseEquity;

  Member({
    required this.id,
    required this.name,
    this.phone = '',
    this.baseEquity = 0.0,
  });

  double get effectiveEquity {
    // TODO: Calculate effective equity based on all transactions
    return baseEquity;
  }

  Member copyWith({String? name, String? phone, double? baseEquity}) {
    return Member(
      id: id,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      baseEquity: baseEquity ?? this.baseEquity,
    );
  }
}
