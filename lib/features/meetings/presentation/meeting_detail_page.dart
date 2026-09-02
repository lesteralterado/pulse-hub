import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/utils/error_presenter.dart';
import '../../auth/application/auth_providers.dart';
import '../application/meeting_providers.dart';
import '../domain/meeting.dart';
import 'meeting_call_page.dart';
import 'meeting_chat_page.dart';

class MeetingDetailPage extends ConsumerStatefulWidget {
  const MeetingDetailPage({super.key, required this.meeting});

  final Meeting meeting;

  @override
  ConsumerState<MeetingDetailPage> createState() => _MeetingDetailPageState();
}

class _MeetingDetailPageState extends ConsumerState<MeetingDetailPage> {
  bool _isSubmitting = false;
  late String? _myRsvpStatus = widget.meeting.myRsvpStatus;
  late String _status = widget.meeting.status;
  late bool _locked = widget.meeting.locked;

  Future<void> _toggleRsvp() async {
    setState(() => _isSubmitting = true);
    final repository = ref.read(meetingRepositoryProvider);
    final result = _myRsvpStatus == 'going'
        ? await repository.cancelRsvp(widget.meeting.id)
        : await repository.rsvp(widget.meeting.id);
    if (!mounted) return;

    result.when(
      success: (_) {
        setState(() {
          _myRsvpStatus = _myRsvpStatus == 'going' ? null : 'going';
          _isSubmitting = false;
        });
        ref.invalidate(meetingParticipantsProvider(widget.meeting.id));
      },
      failure: (error) {
        setState(() => _isSubmitting = false);
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(describeError(error))));
      },
    );
  }

  Future<void> _startMeeting() async {
    setState(() => _isSubmitting = true);
    final result = await ref.read(meetingRepositoryProvider).startMeeting(widget.meeting.id);
    if (!mounted) return;

    result.when(
      success: (_) => setState(() {
        _status = 'live';
        _isSubmitting = false;
      }),
      failure: (error) {
        setState(() => _isSubmitting = false);
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(describeError(error))));
      },
    );
  }

  Future<void> _endMeeting() async {
    setState(() => _isSubmitting = true);
    final result = await ref.read(meetingRepositoryProvider).endMeeting(widget.meeting.id);
    if (!mounted) return;

    result.when(
      success: (_) => setState(() {
        _status = 'ended';
        _isSubmitting = false;
      }),
      failure: (error) {
        setState(() => _isSubmitting = false);
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(describeError(error))));
      },
    );
  }

  Future<void> _toggleLock() async {
    setState(() => _isSubmitting = true);
    final newLocked = !_locked;
    final result = await ref
        .read(meetingRepositoryProvider)
        .setLocked(meetingId: widget.meeting.id, locked: newLocked);
    if (!mounted) return;

    result.when(
      success: (_) => setState(() {
        _locked = newLocked;
        _isSubmitting = false;
      }),
      failure: (error) {
        setState(() => _isSubmitting = false);
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(describeError(error))));
      },
    );
  }

  Future<void> _removeParticipant(String userId) async {
    final result = await ref
        .read(meetingRepositoryProvider)
        .removeParticipant(meetingId: widget.meeting.id, userId: userId);
    if (!mounted) return;

    result.when(
      success: (_) => ref.invalidate(meetingParticipantsProvider(widget.meeting.id)),
      failure: (error) => ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(describeError(error)))),
    );
  }

  Future<void> _joinCall() async {
    await ref.read(meetingRepositoryProvider).recordJoin(widget.meeting.id);
    if (!mounted) return;
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => MeetingCallPage(meeting: widget.meeting)),
    );
  }

  String _formatDateTime(DateTime dateTime) {
    final local = dateTime.toLocal();
    final month = local.month.toString().padLeft(2, '0');
    final day = local.day.toString().padLeft(2, '0');
    final hour = local.hour.toString().padLeft(2, '0');
    final minute = local.minute.toString().padLeft(2, '0');
    return '${local.year}-$month-$day $hour:$minute';
  }

  @override
  Widget build(BuildContext context) {
    final meeting = widget.meeting;
    final theme = Theme.of(context);
    final currentUserId = ref.watch(currentUserProvider)?.id;
    final isHost = currentUserId == meeting.hostId;
    final isGoing = _myRsvpStatus == 'going';
    final participantsAsync = ref.watch(meetingParticipantsProvider(meeting.id));

    return Scaffold(
      appBar: AppBar(
        title: Text(meeting.title),
        actions: [
          IconButton(
            icon: const Icon(Icons.chat_bubble_outline),
            tooltip: 'Meeting chat',
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => MeetingChatPage(meetingId: meeting.id)),
            ),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          if (meeting.description?.isNotEmpty ?? false) ...[
            Text(meeting.description!, style: theme.textTheme.bodyMedium),
            const SizedBox(height: 12),
          ],
          Row(
            children: [
              const Icon(Icons.schedule, size: 18),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  '${_formatDateTime(meeting.scheduledStart)} - ${_formatDateTime(meeting.scheduledEnd)}',
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text('Hosted by ${meeting.hostDisplayName}', style: theme.textTheme.bodyMedium),
          const SizedBox(height: 16),
          if (_status == 'live')
            FilledButton.icon(
              onPressed: _joinCall,
              icon: const Icon(Icons.videocam),
              label: const Text('Join call'),
            )
          else if (!isHost && (_status == 'scheduled'))
            OutlinedButton.icon(
              onPressed: _isSubmitting ? null : _toggleRsvp,
              icon: Icon(isGoing ? Icons.check_circle : Icons.event_available),
              label: Text(isGoing ? 'Cancel RSVP' : 'RSVP'),
            ),
          if (isHost) ...[
            const SizedBox(height: 12),
            Text('Host controls', style: theme.textTheme.titleMedium),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                if (_status == 'scheduled')
                  FilledButton(
                    onPressed: _isSubmitting ? null : _startMeeting,
                    child: const Text('Start meeting'),
                  ),
                if (_status == 'live')
                  OutlinedButton(
                    onPressed: _isSubmitting ? null : _endMeeting,
                    child: const Text('End meeting'),
                  ),
                OutlinedButton.icon(
                  onPressed: _isSubmitting ? null : _toggleLock,
                  icon: Icon(_locked ? Icons.lock : Icons.lock_open),
                  label: Text(_locked ? 'Unlock' : 'Lock'),
                ),
              ],
            ),
          ],
          const SizedBox(height: 20),
          Text('Participants', style: theme.textTheme.titleMedium),
          const SizedBox(height: 8),
          participantsAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (error, _) => Text(describeError(error)),
            data: (participants) => Column(
              children: participants.map((participant) {
                final initial = participant.displayName.isNotEmpty
                    ? participant.displayName[0].toUpperCase()
                    : '?';
                return ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: CircleAvatar(child: Text(initial)),
                  title: Text(participant.displayName),
                  subtitle: Text(
                    participant.isHost
                        ? 'Host'
                        : (participant.isCoHost ? 'Co-host' : 'Participant'),
                  ),
                  trailing: (isHost && participant.userId != currentUserId)
                      ? IconButton(
                          icon: const Icon(Icons.remove_circle_outline),
                          onPressed: () => _removeParticipant(participant.userId),
                        )
                      : null,
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}
