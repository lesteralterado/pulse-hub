/// A row from the `course_summary` view: a published course with its
/// total/completed lesson counts already computed server-side for the
/// current user.
class Course {
  const Course({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.createdAt,
    required this.totalLessons,
    required this.completedLessons,
  });

  final String id;
  final String title;
  final String? description;
  final String category;
  final DateTime createdAt;
  final int totalLessons;
  final int completedLessons;

  bool get isStarted => completedLessons > 0;
  bool get isCompleted => totalLessons > 0 && completedLessons >= totalLessons;

  /// 0.0-1.0, or 0 for an empty course rather than dividing by zero.
  double get completionRatio => totalLessons == 0 ? 0 : completedLessons / totalLessons;

  factory Course.fromMap(Map<String, dynamic> map) {
    return Course(
      id: map['id'] as String,
      title: map['title'] as String,
      description: map['description'] as String?,
      category: map['category'] as String,
      createdAt: DateTime.parse(map['created_at'] as String),
      totalLessons: map['total_lessons'] as int,
      completedLessons: map['completed_lessons'] as int,
    );
  }
}
