import 'package:flutter/material.dart';

import '../../domain/lesson.dart';

class LessonTile extends StatelessWidget {
  const LessonTile({super.key, required this.lesson, required this.onTap});

  final Lesson lesson;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        onTap: onTap,
        leading: Icon(
          lesson.isCompleted
              ? Icons.check_circle
              : (lesson.isLink ? Icons.link_outlined : Icons.article_outlined),
          color: lesson.isCompleted ? Theme.of(context).colorScheme.primary : null,
        ),
        title: Text(lesson.title),
      ),
    );
  }
}
