/// A row from the `group_summary` view, which joins the current member
/// count and whether the querying user has already joined.
class Group {
  const Group({
    required this.id,
    required this.name,
    required this.description,
    required this.createdBy,
    required this.createdAt,
    required this.memberCount,
    required this.isMember,
  });

  final String id;
  final String name;
  final String? description;
  final String createdBy;
  final DateTime createdAt;
  final int memberCount;
  final bool isMember;

  factory Group.fromMap(Map<String, dynamic> map) {
    return Group(
      id: map['id'] as String,
      name: map['name'] as String,
      description: map['description'] as String?,
      createdBy: map['created_by'] as String,
      createdAt: DateTime.parse(map['created_at'] as String),
      memberCount: map['member_count'] as int,
      isMember: map['is_member'] as bool,
    );
  }
}
