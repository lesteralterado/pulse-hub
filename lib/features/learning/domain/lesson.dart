/// A row from the `lesson_summary` view: a lesson with its module info
/// and the current user's progress already joined server-side.
class Lesson {
  const Lesson({
    required this.id,
    required this.moduleId,
    required this.title,
    required this.contentType,
    required this.content,
    required this.lessonPosition,
    required this.courseId,
    required this.moduleTitle,
    required this.modulePosition,
    required this.viewedAt,
    required this.completedAt,
  });

  final String id;
  final String moduleId;
  final String title;

  /// 'text' (rendered as-is) or 'link' (an external URL).
  final String contentType;
  final String content;
  final int lessonPosition;
  final String courseId;
  final String moduleTitle;
  final int modulePosition;
  final DateTime? viewedAt;
  final DateTime? completedAt;

  bool get isLink => contentType == 'link';
  bool get isCompleted => completedAt != null;

  factory Lesson.fromMap(Map<String, dynamic> map) {
    final viewedAt = map['viewed_at'] as String?;
    final completedAt = map['completed_at'] as String?;
    return Lesson(
      id: map['id'] as String,
      moduleId: map['module_id'] as String,
      title: map['title'] as String,
      contentType: map['content_type'] as String,
      content: map['content'] as String,
      lessonPosition: map['lesson_position'] as int,
      courseId: map['course_id'] as String,
      moduleTitle: map['module_title'] as String,
      modulePosition: map['module_position'] as int,
      viewedAt: viewedAt == null ? null : DateTime.parse(viewedAt),
      completedAt: completedAt == null ? null : DateTime.parse(completedAt),
    );
  }
}
