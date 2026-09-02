import 'package:flutter_test/flutter_test.dart';
import 'package:pulsehub/core/utils/relative_time.dart';

void main() {
  final now = DateTime.utc(2026, 1, 10, 12);

  group('formatRelativeTime', () {
    test('under a minute reads "just now"', () {
      final result = formatRelativeTime(
        now.subtract(const Duration(seconds: 30)),
        now: now,
      );
      expect(result, 'just now');
    });

    test('minutes ago', () {
      final result = formatRelativeTime(
        now.subtract(const Duration(minutes: 5)),
        now: now,
      );
      expect(result, '5m ago');
    });

    test('hours ago', () {
      final result = formatRelativeTime(
        now.subtract(const Duration(hours: 3)),
        now: now,
      );
      expect(result, '3h ago');
    });

    test('days ago, under a week', () {
      final result = formatRelativeTime(
        now.subtract(const Duration(days: 2)),
        now: now,
      );
      expect(result, '2d ago');
    });

    test('falls back to an absolute date after a week', () {
      final result = formatRelativeTime(
        DateTime.utc(2025, 12, 1),
        now: now,
      );
      expect(result, '2025-12-01');
    });
  });
}
