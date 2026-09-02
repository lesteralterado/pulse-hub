import 'package:flutter_test/flutter_test.dart';
import 'package:pulsehub/features/community/domain/group.dart';

void main() {
  group('Group.fromMap', () {
    test('parses all fields from a group_summary row', () {
      final group = Group.fromMap({
        'id': 'g1',
        'name': 'BOT Chain Community',
        'description': 'Discuss BOT Chain',
        'created_by': 'u1',
        'created_at': '2026-01-01T00:00:00Z',
        'member_count': 42,
        'is_member': true,
      });

      expect(group.id, 'g1');
      expect(group.name, 'BOT Chain Community');
      expect(group.memberCount, 42);
      expect(group.isMember, isTrue);
    });

    test('handles a null description', () {
      final group = Group.fromMap({
        'id': 'g1',
        'name': 'Announcements',
        'description': null,
        'created_by': 'u1',
        'created_at': '2026-01-01T00:00:00Z',
        'member_count': 0,
        'is_member': false,
      });

      expect(group.description, isNull);
      expect(group.isMember, isFalse);
    });
  });
}
