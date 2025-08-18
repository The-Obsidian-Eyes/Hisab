import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:hisab/core/common/models.dart';
import '../../../../core/providers/app_state.dart';
import 'stat_cards.dart';
import 'member_profile_dialogs.dart';

class MemberProfileHeader extends StatelessWidget {
  final Member member;
  final String memberId;
  final List<Entry> entries;

  const MemberProfileHeader({
    super.key,
    required this.member,
    required this.memberId,
    required this.entries,
  });

  @override
  Widget build(BuildContext context) {
    final s = context.watch<AppState>();

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Card(
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              CircleAvatar(
                radius: 48,
                backgroundColor: Colors.indigo.shade50,
                child: Text(
                  member.name.isNotEmpty ? member.name[0].toUpperCase() : '?',
                  style: const TextStyle(
                    fontSize: 32,
                    color: Colors.indigo,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                member.name,
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    member.phone.isEmpty ? 'No phone number' : member.phone,
                    style: Theme.of(
                      context,
                    ).textTheme.bodyMedium?.copyWith(color: Colors.grey),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    onPressed: () => showEditPhoneDialog(context, member),
                    icon: const Icon(Icons.edit),
                    iconSize: 16,
                    style: IconButton.styleFrom(
                      padding: const EdgeInsets.all(4),
                      backgroundColor: Colors.grey[100],
                    ),
                    tooltip: 'Edit phone number',
                  ),
                ],
              ),
              const SizedBox(height: 24),
              // Stats Row
              Wrap(
                spacing: 12,
                runSpacing: 12,
                alignment: WrapAlignment.center,
                children: [
                  StatCard(
                    title: 'Base Equity',
                    value:
                        '\$${s.memberBaseEquity(memberId).toStringAsFixed(2)}',
                    color: Colors.blue,
                    icon: Icons.account_balance_wallet,
                  ),
                  StatCard(
                    title: 'Effective Equity',
                    value:
                        '\$${s.memberEffectiveEquity(memberId).toStringAsFixed(2)}',
                    color: Colors.green,
                    icon: Icons.trending_up,
                  ),
                  ShareStatCard(
                    percentage: s.memberEquityPercentage(memberId),
                    value:
                        '\$${s.memberEffectiveEquity(memberId).toStringAsFixed(2)}',
                    color: Colors.indigo,
                  ),
                  if (s.totalProfitLoss != 0)
                    StatCard(
                      title: 'Profit/Loss Share',
                      value:
                          '\$${(s.totalProfitLoss * (s.memberBaseEquity(memberId) / s.totalBaseEquity)).toStringAsFixed(2)}',
                      color: s.totalProfitLoss > 0 ? Colors.green : Colors.red,
                      icon:
                          s.totalProfitLoss > 0
                              ? Icons.arrow_upward
                              : Icons.arrow_downward,
                    ),
                ],
              ),
              const SizedBox(height: 16),
              // Action Buttons
              Row(
                children: [
                  Expanded(
                    child: FilledButton.icon(
                      onPressed: () => showAddEquityDialog(context, memberId),
                      icon: const Icon(Icons.add),
                      label: const Text('Add Equity'),
                      style: FilledButton.styleFrom(
                        backgroundColor: Colors.indigo,
                        minimumSize: const Size(double.infinity, 45),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: FilledButton.icon(
                      onPressed: () => showDeleteEquityDialog(context, entries),
                      icon: const Icon(Icons.remove),
                      label: const Text('Delete Equity'),
                      style: FilledButton.styleFrom(
                        backgroundColor: Colors.red,
                        minimumSize: const Size(double.infinity, 45),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
