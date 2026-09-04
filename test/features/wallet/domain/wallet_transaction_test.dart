import 'package:flutter_test/flutter_test.dart';
import 'package:pulsehub/features/wallet/domain/wallet_transaction.dart';

void main() {
  group('WalletTransaction.fromMap', () {
    test('parses a send transaction', () {
      final tx = WalletTransaction.fromMap({
        'id': 't1',
        'tx_hash': '0xabc',
        'direction': 'send',
        'amount': 10,
        'counterparty_address': '0xdef',
        'status': 'confirmed',
        'created_at': '2026-01-01T00:00:00Z',
      });

      expect(tx.isSend, isTrue);
      expect(tx.amount, 10);
    });

    test('parses a receive transaction', () {
      final tx = WalletTransaction.fromMap({
        'id': 't1',
        'tx_hash': '0xabc',
        'direction': 'receive',
        'amount': 5.5,
        'counterparty_address': null,
        'status': 'pending',
        'created_at': '2026-01-01T00:00:00Z',
      });

      expect(tx.isSend, isFalse);
      expect(tx.status, 'pending');
    });
  });
}
