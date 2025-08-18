import 'package:flutter/material.dart';
import 'package:hisab/core/common/models.dart';
import 'profit_distribution_row.dart';

class ProfitDistributionList extends StatelessWidget {
  final List<Member> members;
  final Map<String, TextEditingController> percentageControllers;
  final bool useCustom;

  const ProfitDistributionList({
    super.key,
    required this.members,
    required this.percentageControllers,
    required this.useCustom,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 80),
      itemCount: members.length,
      itemBuilder: (context, index) {
        final member = members[index];
        final equityPercentage = 0.0; // placeholder; main view calculates
        final valuePreview = 0.0;
        return ProfitDistributionRow(
          member: member,
          equityPercentage: equityPercentage,
          value: valuePreview,
          useCustom: useCustom,
          percentageController: percentageControllers[member.id],
        );
      },
    );
  }
}
