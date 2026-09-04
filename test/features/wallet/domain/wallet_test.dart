import 'package:flutter_test/flutter_test.dart';
import 'package:pulsehub/features/wallet/domain/wallet.dart';

void main() {
  group('Wallet.fromMap', () {
    test('parses all fields', () {
      final wallet = Wallet.fromMap({
        'id': 'w1',
        'user_id': 'u1',
        'address': '0x1234567890abcdef1234567890abcdef12345678',
        'created_at': '2026-01-01T00:00:00Z',
      });

      expect(wallet.id, 'w1');
      expect(wallet.userId, 'u1');
    });
  });

  group('Wallet.displayAddress', () {
    test('abbreviates a long address', () {
      final wallet = Wallet(
        id: 'w1',
        userId: 'u1',
        address: '0x1234567890abcdef1234567890abcdef12345678',
        createdAt: DateTime.utc(2026, 1, 1),
      );

      expect(wallet.displayAddress, '0x1234...5678');
    });

    test('leaves a short address as-is', () {
      final wallet = Wallet(
        id: 'w1',
        userId: 'u1',
        address: 'short-addr',
        createdAt: DateTime.utc(2026, 1, 1),
      );

      expect(wallet.displayAddress, 'short-addr');
    });
  });
}
