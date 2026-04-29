enum WalletSyncStatus {
  idle,
  syncing,
  synced,
  failed,
}

class WalletSyncState {
  final WalletSyncStatus status;
  final DateTime? lastSyncedAt;
  final String? errorMessage;

  const WalletSyncState({
    required this.status,
    this.lastSyncedAt,
    this.errorMessage,
  });

  factory WalletSyncState.idle() {
    return const WalletSyncState(status: WalletSyncStatus.idle);
  }

  factory WalletSyncState.syncing() {
    return const WalletSyncState(status: WalletSyncStatus.syncing);
  }

  factory WalletSyncState.synced() {
    return WalletSyncState(
      status: WalletSyncStatus.synced,
      lastSyncedAt: DateTime.now(),
    );
  }

  factory WalletSyncState.failed(String message) {
    return WalletSyncState(
      status: WalletSyncStatus.failed,
      errorMessage: message,
    );
  }
}
