import 'package:flutter_test/flutter_test.dart';
import 'package:pulsehub/core/utils/validators.dart';

void main() {
  group('Validators.email', () {
    test('rejects empty input', () {
      expect(Validators.email(''), 'Email is required');
      expect(Validators.email(null), 'Email is required');
    });

    test('rejects a string without @', () {
      expect(Validators.email('not-an-email'), 'Enter a valid email address');
    });

    test('rejects a string without a domain', () {
      expect(Validators.email('user@'), 'Enter a valid email address');
    });

    test('accepts a well-formed email', () {
      expect(Validators.email('user@example.com'), isNull);
    });

    test('trims surrounding whitespace before validating', () {
      expect(Validators.email('  user@example.com  '), isNull);
    });
  });

  group('Validators.password', () {
    test('rejects empty input', () {
      expect(Validators.password(''), 'Password is required');
      expect(Validators.password(null), 'Password is required');
    });

    test('rejects passwords shorter than 8 characters', () {
      expect(Validators.password('short1'), 'Password must be at least 8 characters');
    });

    test('accepts an 8+ character password', () {
      expect(Validators.password('longenough1'), isNull);
    });
  });

  group('Validators.confirmPassword', () {
    test('rejects a mismatch', () {
      expect(
        Validators.confirmPassword('different', 'original'),
        'Passwords do not match',
      );
    });

    test('accepts a match', () {
      expect(Validators.confirmPassword('same-value', 'same-value'), isNull);
    });
  });
}
