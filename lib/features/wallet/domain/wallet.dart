/// A row from the `wallets` table: the current user's connected wallet
/// address (read-only/watch mode — see the Phase 8 scoping discussion,
/// no custodial key custody here).
class Wallet {
  const Wallet({required this.id, required this.userId, required this.address, required this.createdAt});

  final String id;
  final String userId;
  final String address;
  final DateTime createdAt;

  /// e.g. "0x1234...abcd" for display — never the full address in list
  /// views, matching how most wallet UIs abbreviate addresses.
  String get displayAddress {
    if (address.length <= 12) return address;
    return '${address.substring(0, 6)}...${address.substring(address.length - 4)}';
  }

  factory Wallet.fromMap(Map<String, dynamic> map) {
    return Wallet(
      id: map['id'] as String,
      userId: map['user_id'] as String,
      address: map['address'] as String,
      createdAt: DateTime.parse(map['created_at'] as String),
    );
  }
}
