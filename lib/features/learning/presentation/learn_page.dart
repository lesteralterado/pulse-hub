import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/utils/error_presenter.dart';
import '../application/learning_providers.dart';
import '../domain/course.dart';
import 'course_detail_page.dart';
import 'widgets/course_card.dart';

/// The Learning Center (section 13 of the brief): courses grouped by
/// category. Course/lesson authoring has no UI here — the brief places
/// that under the separate Admin Dashboard (Phase 11) — so this page is
/// read/progress-only.
class LearnPage extends ConsumerWidget {
  const LearnPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final coursesAsync = ref.watch(coursesProvider);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Learn')),
      body: RefreshIndicator(
        onRefresh: () async => ref.invalidate(coursesProvider),
        child: coursesAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, _) => ListView(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 64),
                child: Center(child: Text(describeError(error))),
              ),
            ],
          ),
          data: (courses) {
            if (courses.isEmpty) {
              return ListView(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 64),
                    child: Center(
                      child: Text(
                        'No courses available yet.',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ),
                  ),
                ],
              );
            }

            final byCategory = <String, List<Course>>{};
            for (final course in courses) {
              byCategory.putIfAbsent(course.category, () => []).add(course);
            }

            return ListView(
              padding: const EdgeInsets.all(16),
              children: [
                for (final category in byCategory.keys) ...[
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8, top: 8),
                    child: Text(category, style: theme.textTheme.titleMedium),
                  ),
                  for (final course in byCategory[category]!) ...[
                    CourseCard(
                      course: course,
                      onTap: () => Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => CourseDetailPage(course: course),
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                  ],
                  const SizedBox(height: 8),
                ],
              ],
            );
          },
        ),
      ),
    );
  }
}
