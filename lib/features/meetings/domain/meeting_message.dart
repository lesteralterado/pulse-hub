/// A row from the `meeting_messages` table. Like chat's `Message`, this
/// has no embedded sender info -- the realtime stream it's parsed from
/// only supports plain table columns -- so the UI resolves `senderId`
/// against the already-fetched participant list.
class MeetingMessage {
  const MeetingMessage({
    required this.id,
    required this.meetingId,
    required this.senderId,
    required this.content,
    required this.createdAt,
  });

  final String id;
  final String meetingId;
  final String senderId;
  final String content;
  final DateTime createdAt;

  factory MeetingMessage.fromMap(Map<String, dynamic> map) {
    return MeetingMessage(
      id: map['id'] as String,
      meetingId: map['meeting_id'] as String,
      senderId: map['sender_id'] as String,
      content: map['content'] as String,
      createdAt: DateTime.parse(map['created_at'] as String),
    );
  }
}
