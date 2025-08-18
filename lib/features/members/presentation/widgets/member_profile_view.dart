import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/providers/app_state.dart';

import 'member_profile_header.dart';
import 'member_history_list.dart';

class MemberProfileView extends StatelessWidget {
  final String memberId;

  const MemberProfileView({super.key, required this.memberId});

  @override
  Widget build(BuildContext context) {
    final s = context.watch<AppState>();
    final member = s.members.firstWhere((m) => m.id == memberId);
    final entries =
        s.entries
            .where((e) => e.type == 'equity' && e.memberId == memberId)
            .toList()
          ..sort((a, b) => b.date.compareTo(a.date));

    return Scaffold(
      appBar: AppBar(
        title: Text(member.name),
        backgroundColor: Colors.transparent,
        elevation: 0,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF4F8CFF), Color(0xFF6FE7FF)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFE3F0FF), Color(0xFFF8FBFF)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Column(
          children: [
            MemberProfileHeader(
              member: member,
              memberId: memberId,
              entries: entries,
            ),
            // History Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  Icon(Icons.history, color: Colors.grey[700], size: 20),
                  const SizedBox(width: 8),
                  Text(
                    'Transaction History',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[800],
                    ),
                  ),
                  const Spacer(),
                  Text(
                    '${entries.length} entries',
                    style: Theme.of(
                      context,
                    ).textTheme.bodySmall?.copyWith(color: Colors.grey[600]),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            // Transaction List
            Expanded(child: MemberHistoryList(entries: entries)),
          ],
        ),
      ),
    );
  }
}
