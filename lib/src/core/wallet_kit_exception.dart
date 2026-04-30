class WalletKitException implements Exception {
  final String message;
  final Object? cause;

  const WalletKitException(this.message, [this.cause]);

  @override
  String toString() => 'WalletKitException: $message';
}

class WalletNotInitializedException extends WalletKitException {
  const WalletNotInitializedException()
    : super('Wallet is not initialized. Create or restore a wallet first.');
}
