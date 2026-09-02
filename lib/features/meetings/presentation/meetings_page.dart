import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/utils/error_presenter.dart';
import '../application/meeting_providers.dart';
import 'create_meeting_page.dart';
import 'meeting_detail_page.dart';
import 'widgets/meeting_card.dart';

class MeetingsPage extends ConsumerWidget {
  const MeetingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final meetingsAsync = ref.watch(meetingsProvider);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Meetings')),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => const CreateMeetingPage()),
        ),
        child: const Icon(Icons.add),
      ),
      body: RefreshIndicator(
        onRefresh: () async => ref.invalidate(meetingsProvider),
        child: meetingsAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, _) => ListView(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 64),
                child: Center(child: Text(describeError(error))),
              ),
            ],
          ),
          data: (meetings) => meetings.isEmpty
              ? ListView(
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 64),
                      child: Center(
                        child: Text(
                          'No meetings scheduled yet.',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ),
                    ),
                  ],
                )
              : ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: meetings.length,
                  separatorBuilder: (context, index) => const SizedBox(height: 8),
                  itemBuilder: (context, index) {
                    final meeting = meetings[index];
                    return MeetingCard(
                      meeting: meeting,
                      onTap: () async {
                        await Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => MeetingDetailPage(meeting: meeting),
                          ),
                        );
                        ref.invalidate(meetingsProvider);
                      },
                    );
                  },
                ),
        ),
      ),
    );
  }
}
