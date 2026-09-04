/// A row from the `transactions` table. The table is real (matches the
/// brief's schema) but stays empty until a backend job can sync it from
/// the chain — see the migration comment. Reading this always succeeds;
/// it just returns nothing yet.
class WalletTransaction {
  const WalletTransaction({
    required this.id,
    required this.txHash,
    required this.direction,
    required this.amount,
    required this.counterpartyAddress,
    required this.status,
    required this.createdAt,
  });

  final String id;
  final String txHash;

  /// 'send' or 'receive'.
  final String direction;
  final num amount;
  final String? counterpartyAddress;

  /// 'pending' | 'confirmed' | 'failed'.
  final String status;
  final DateTime createdAt;

  bool get isSend => direction == 'send';

  factory WalletTransaction.fromMap(Map<String, dynamic> map) {
    return WalletTransaction(
      id: map['id'] as String,
      txHash: map['tx_hash'] as String,
      direction: map['direction'] as String,
      amount: map['amount'] as num,
      counterpartyAddress: map['counterparty_address'] as String?,
      status: map['status'] as String,
      createdAt: DateTime.parse(map['created_at'] as String),
    );
  }
}
