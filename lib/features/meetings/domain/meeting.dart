/// A row from the `meeting_summary` view: a meeting with its host's
/// profile, the going-participant count, and the current user's RSVP
/// already joined server-side.
class Meeting {
  const Meeting({
    required this.id,
    required this.hostId,
    required this.title,
    required this.description,
    required this.scheduledStart,
    required this.scheduledEnd,
    required this.status,
    required this.locked,
    required this.createdAt,
    required this.hostUsername,
    required this.hostFullName,
    required this.participantCount,
    required this.myRsvpStatus,
  });

  final String id;
  final String hostId;
  final String title;
  final String? description;
  final DateTime scheduledStart;
  final DateTime scheduledEnd;

  /// 'scheduled' | 'live' | 'ended' | 'cancelled'. "Starting Soon" (the
  /// 4th state from the brief) is computed, not stored — see
  /// [isStartingSoon].
  final String status;
  final bool locked;
  final DateTime createdAt;
  final String? hostUsername;
  final String? hostFullName;
  final int participantCount;

  /// null means the current user hasn't RSVPed.
  final String? myRsvpStatus;

  String get hostDisplayName =>
      (hostFullName?.isNotEmpty ?? false) ? hostFullName! : (hostUsername ?? 'Someone');

  bool get isGoing => myRsvpStatus == 'going';
  bool get isLive => status == 'live';
  bool get isEnded => status == 'ended' || status == 'cancelled';

  bool get isStartingSoon {
    if (status != 'scheduled') return false;
    final now = DateTime.now();
    return scheduledStart.isAfter(now) &&
        scheduledStart.difference(now) <= const Duration(minutes: 15);
  }

  /// A short label for the meeting list: Live, Starting soon, Scheduled,
  /// Ended, or Cancelled.
  String get displayStatus {
    if (status == 'cancelled') return 'Cancelled';
    if (status == 'ended') return 'Ended';
    if (status == 'live') return 'Live';
    if (isStartingSoon) return 'Starting soon';
    return 'Scheduled';
  }

  factory Meeting.fromMap(Map<String, dynamic> map) {
    return Meeting(
      id: map['id'] as String,
      hostId: map['host_id'] as String,
      title: map['title'] as String,
      description: map['description'] as String?,
      scheduledStart: DateTime.parse(map['scheduled_start'] as String),
      scheduledEnd: DateTime.parse(map['scheduled_end'] as String),
      status: map['status'] as String,
      locked: map['locked'] as bool,
      createdAt: DateTime.parse(map['created_at'] as String),
      hostUsername: map['host_username'] as String?,
      hostFullName: map['host_full_name'] as String?,
      participantCount: map['participant_count'] as int,
      myRsvpStatus: map['my_rsvp_status'] as String?,
    );
  }
}
