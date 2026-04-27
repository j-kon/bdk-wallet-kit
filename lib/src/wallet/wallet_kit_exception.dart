class WalletKitException implements Exception {
  final String message;
  final Object? cause;

  const WalletKitException(this.message, [this.cause]);

  @override
  String toString() => 'WalletKitException: $message';
}
