import 'package:flutter/material.dart';

import '../../../core/widgets/coming_soon_page.dart';

/// Placeholder for the Learning Center (courses, quizzes — Phase 6).
class LearnPage extends StatelessWidget {
  const LearnPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const ComingSoonPage(
      title: 'Learn',
      icon: Icons.school_outlined,
      message:
          'Courses on BOT Chain, CaryPact and blockchain basics\n'
          'are coming soon.',
    );
  }
}
