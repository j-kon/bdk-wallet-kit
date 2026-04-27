class TransactionResult {
  final String txid;
  final bool broadcasted;
  final DateTime createdAt;

  const TransactionResult({
    required this.txid,
    required this.broadcasted,
    required this.createdAt,
  });
}
