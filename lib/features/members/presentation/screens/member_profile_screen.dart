import 'package:flutter/material.dart';

import '../widgets/member_profile_view.dart';

class MemberProfileScreen extends StatelessWidget {
  final String memberId;

  const MemberProfileScreen({super.key, required this.memberId});

  @override
  Widget build(BuildContext context) => MemberProfileView(memberId: memberId);
}
