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

  const WalletSyncState.idle()
      : status = WalletSyncStatus.idle,
        lastSyncedAt = null,
        errorMessage = null;

  const WalletSyncState.syncing()
      : status = WalletSyncStatus.syncing,
        lastSyncedAt = null,
        errorMessage = null;

  WalletSyncState.synced()
      : status = WalletSyncStatus.synced,
        lastSyncedAt = DateTime.now(),
        errorMessage = null;

  const WalletSyncState.failed(String message)
      : status = WalletSyncStatus.failed,
        lastSyncedAt = null,
        errorMessage = message;
}
