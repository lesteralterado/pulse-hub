import 'package:flutter/material.dart';

import '../../../core/widgets/coming_soon_page.dart';

/// Placeholder for the Community section (feed, posts, groups — Phase 4).
class CommunityPage extends StatelessWidget {
  const CommunityPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const ComingSoonPage(
      title: 'Community',
      icon: Icons.groups_outlined,
      message:
          'Posts, groups and discussions are coming soon.\n'
          "You'll be able to follow communities like BOT Chain and "
          'CaryPact Investors right here.',
    );
  }
}
