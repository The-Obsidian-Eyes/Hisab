import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../../features/members/domain/entities/member.dart';
import '../db/entry.dart';

const entryType = {
  'sale',
  'purchase',
  'expense',
  'asset',
  'interest',
  'equity',
  'cash',
};

class AppState extends ChangeNotifier {
  late Box<Member> _membersBox;
  late Box<Entry> _entriesBox;

  Future<void> init() async {
    _membersBox = await Hive.openBox<Member>('members');
    _entriesBox = await Hive.openBox<Entry>('entries');
  }

  List<Member> get members => List.unmodifiable(_membersBox.values);

  Future<void> updateMemberEquity(String memberId, double newBaseEquity) async {
    final member = _membersBox.get(memberId);
    if (member != null) {
      final updatedMember = member.copyWith(baseEquity: newBaseEquity);
      await _membersBox.put(memberId, updatedMember);
      notifyListeners();
    }
  }

  Future<void> addEquity(String memberId, double amount) async {
    final member = _membersBox.get(memberId);
    if (member != null) {
      // Update member's base equity
      final newBaseEquity = member.baseEquity + amount;
      final updatedMember = member.copyWith(baseEquity: newBaseEquity);
      await _membersBox.put(memberId, updatedMember);

      // Add an equity entry
      final now = DateTime.now();
      final entry = Entry(
        id: now.microsecondsSinceEpoch.toString(),
        date: now,
        amount: amount,
        type: 'equity',
        memberId: memberId,
        notes: 'Equity contribution',
      );
      await _entriesBox.add(entry);

      notifyListeners();
    }
  }

  /// Returns a sorted copy (new list) to avoid mutating the source.
  List<Entry> get entries {
    final copy = List<Entry>.from(_entriesBox.values);
    copy.sort((a, b) => b.date.compareTo(a.date));
    return List.unmodifiable(copy);
  }

  /// Gets the base equity amount for a member (stored base value)
  double memberBaseEquity(String memberId) {
    final member = _membersBox.get(memberId);
    return member?.baseEquity ?? 0.0;
  }

  /// Gets the total base equity (sum of all members' base equity)
  double get totalBaseEquity {
    var total = 0.0;
    for (final member in members) {
      total += member.baseEquity;
    }
    return total;
  }

  /// Gets the profit or loss amount from sales and other transactions
  double get totalProfitLoss {
    final revenue = entries
        .where((e) => e.type == 'sale' || e.type == 'interest')
        .fold<double>(0, (sum, e) => sum + e.amount);

    final costs = entries
        .where((e) => e.type == 'purchase') // Don't include expenses here
        .fold<double>(0, (sum, e) => sum + e.amount);

    return revenue - costs;
  }

  /// Gets the effective equity for a member including their share of profits/losses and expenses
  double memberEffectiveEquity(String memberId) {
    final baseEquity = memberBaseEquity(memberId);
    final baseTotal = totalBaseEquity;

    if (baseTotal <= 0) return 0;

    // Calculate share percentage
    final share = baseEquity / baseTotal;

    // Calculate expense share
    final expenseShare = totalExpenses * share;

    // Calculate profit/loss share
    final profitLossShare = totalProfitLoss * share;

    return baseEquity - expenseShare + profitLossShare;
  }

  /// Gets member's equity percentage including profits/losses
  double memberEquityPercentage(String memberId) {
    // The share should be computed relative to the sum of all members'
    // effective equities (i.e. each member's effective equity divided by
    // the total of effective equities). Using totalEffectiveEquity
    // (which was baseEquity + totalProfitLoss) is incorrect when there are
    // expenses because the sum of memberEffectiveEquity values equals
    // totalBaseEquity - totalExpenses + totalProfitLoss, not
    // totalBaseEquity + totalProfitLoss. Compute the actual total of
    // member effective equities to ensure percentages sum to 100%.
    final effectiveSum = members.fold<double>(
      0.0,
      (sum, m) => sum + memberEffectiveEquity(m.id),
    );
    if (effectiveSum <= 0) return 0;
    return (memberEffectiveEquity(memberId) / effectiveSum) * 100;
  }

  /// Gets the total effective equity including all profits/losses
  double get totalEffectiveEquity {
    final baseEquity = totalBaseEquity;
    return baseEquity + totalProfitLoss;
  }

  // ----- Mutations -----
  Future<void> addMember(String name, {String phone = ''}) async {
    final member = Member(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: name,
      phone: phone,
    );
    await _membersBox.put(member.id, member);
    notifyListeners();
  }

  Future<void> updateMemberPhone(String id, String phone) async {
    final member = _membersBox.get(id);
    if (member != null) {
      final updatedMember = Member(
        id: member.id,
        name: member.name,
        phone: phone,
      );
      await _membersBox.put(id, updatedMember);
      notifyListeners();
    }
  }

  Future<void> removeMember(String id) async {
    await _membersBox.delete(id);
    // Also remove equity entries for this member (optional)
    for (final entry in _entriesBox.values) {
      if (entry.memberId == id) {
        await _entriesBox.delete(entry.id);
      }
    }
    notifyListeners();
  }

  Future<void> addEntry(Entry entry) async {
    await _entriesBox.put(entry.id, entry);

    // If this is an equity entry, update the member's base equity
    if (entry.type == 'equity' && entry.memberId != null) {
      final member = _membersBox.get(entry.memberId);
      if (member != null) {
        final newBaseEquity = member.baseEquity + entry.amount;
        final updatedMember = member.copyWith(baseEquity: newBaseEquity);
        await _membersBox.put(member.id, updatedMember);
      }
    }

    notifyListeners();
  }

  Future<void> deleteEntry(String id) async {
    await _entriesBox.delete(id);
    notifyListeners();
  }

  // ----- Aggregations -----
  double get totalSales => _sum('sale');
  double get totalPurchases => _sum('purchase');
  double get totalExpenses => _sum('expense');
  double get totalAssets => _sum('asset');
  double get totalInterest => _sum('interest');

  /// Gets total equity from all members' base equity
  double get totalEquity => totalBaseEquity;

  double _sum(String type) => _entriesBox.values
      .where((e) => e.type == type)
      .fold(0.0, (p, e) => p + e.amount);

  /// Gross profit (Sales - Purchases)
  double get grossProfit => totalSales - totalPurchases;

  /// Net profit before profit sharing
  double get netProfit => grossProfit + totalInterest - totalExpenses;

  /// Return on Investment (ROI) percentage
  double get roi =>
      totalBaseEquity > 0 ? (netProfit / totalBaseEquity) * 100 : 0;

  /// Cash balance is the sum of all transactions
  double get cashBalance =>
      // Start with base equity (owner capital still considered part of cash) + explicit cash entries
      totalBaseEquity +
      _sum('cash') +
      totalSales +
      totalInterest -
      totalPurchases -
      totalExpenses;

  /// Gets member's total equity from entries
  double memberEquity(String memberId) => _entriesBox.values
      .where((e) => e.type == 'equity' && e.memberId == memberId)
      .fold(0.0, (p, e) => p + e.amount);

  Future<void> resetSeason() async {
    // 1. Compute effective equities for all members first (snapshot).
    //    This prevents sequential updates from changing the base total used
    //    in later calculations and ensures members' percentage shares stay
    //    the same after reset.
    final memberEquities =
        members
            .map((m) => MapEntry(m.id, memberEffectiveEquity(m.id)))
            .toList();

    // 2. Update member base equities using the snapshot
    for (final me in memberEquities) {
      await updateMemberEquity(me.key, me.value);
    }

    // 2. Remove all non-equity, non-asset entries by Hive key. We must delete by
    // Hive key (box key) because some places call box.add(entry) which assigns
    // an integer key different from entry.id. Using the Hive key ensures all
    // matching entries are removed regardless of how they were added.
    final entriesMap = _entriesBox.toMap(); // Map<dynamic, Entry>

    final keysToDelete =
        entriesMap.entries
            .where(
              (kv) => kv.value.type != 'equity' && kv.value.type != 'asset',
            )
            .map((kv) => kv.key)
            .toList();

    if (keysToDelete.isNotEmpty) {
      await _entriesBox.deleteAll(keysToDelete);
    }

    // 3. Remove old equity entries (we'll recreate them below). Delete by Hive key.
    final entriesMapAfter = _entriesBox.toMap();
    final oldEquityKeys =
        entriesMapAfter.entries
            .where((kv) => kv.value.type == 'equity')
            .map((kv) => kv.key)
            .toList();
    if (oldEquityKeys.isNotEmpty) {
      await _entriesBox.deleteAll(oldEquityKeys);
    }

    // 4. Create new equity entries reflecting the updated base equities.
    // Use the snapshot values to ensure consistency.
    for (final me in memberEquities) {
      final entry = Entry(
        id: DateTime.now().microsecondsSinceEpoch.toString(),
        date: DateTime.now(),
        amount: me.value,
        type: 'equity',
        memberId: me.key,
        notes: 'Season reset: Base equity adjusted',
      );
      await _entriesBox.put(entry.id, entry);
    }

    // 5. After clearing non-asset entries, ensure cash balance aligns with
    // desired opening cash: desiredCashSum = -totalAssets so that
    // cashBalance == totalBaseEquity + sum(cash) == totalBaseEquity - totalAssets.
    final totalAssets = _sum('asset');
    final desiredCashSum = -totalAssets;

    if (desiredCashSum != 0) {
      final cashEntry = Entry(
        id: 'season_cash_${DateTime.now().microsecondsSinceEpoch}',
        date: DateTime.now(),
        amount: desiredCashSum,
        type: 'cash',
        notes: 'Season reset cash position',
      );
      // Put directly to avoid touching member base equity.
      await _entriesBox.put(cashEntry.id, cashEntry);
    }

    notifyListeners();
  }

  // Seed demo data

  Future<void> seedDemoData() async {
    if (_membersBox.isNotEmpty || _entriesBox.isNotEmpty) return;

    await addMember('Arif', phone: '017xx');
    await addMember('Foysal', phone: '018xx');

    final members = _membersBox.values.toList();
    final m1 = members.first.id;
    final m2 = members.last.id;

    await addEntry(
      Entry(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        date: DateTime.now(),
        amount: 50000,
        type: 'equity',
        memberId: m1,
        notes: 'Initial',
      ),
    );
    await addEntry(
      Entry(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        date: DateTime.now(),
        amount: 50000,
        type: 'equity',
        memberId: m2,
        notes: 'Initial',
      ),
    );
    await addEntry(
      Entry(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        date: DateTime.now(),
        amount: 20000,
        type: 'purchase',
        notes: 'Raw Materials',
      ),
    );
    await addEntry(
      Entry(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        date: DateTime.now(),
        amount: 8000,
        type: 'expense',
        notes: 'Rent',
      ),
    );
    await addEntry(
      Entry(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        date: DateTime.now(),
        amount: 40000,
        type: 'sale',
        notes: 'Order #1001',
      ),
    );
    await addEntry(
      Entry(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        date: DateTime.now(),
        amount: 1200,
        type: 'interest',
        notes: 'Bank Interest',
      ),
    );
    await addEntry(
      Entry(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        date: DateTime.now(),
        amount: 15000,
        type: 'asset',
        notes: 'Printer',
      ),
    );
  }
}
