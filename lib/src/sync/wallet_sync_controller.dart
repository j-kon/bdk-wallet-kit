import 'wallet_sync_state.dart';

class WalletSyncController {
  WalletSyncState _state = WalletSyncState.idle();

  WalletSyncState get state => _state;

  Future<void> run(Future<void> Function() syncOperation) async {
    _state = WalletSyncState.syncing();

    try {
      await syncOperation();
      _state = WalletSyncState.synced();
    } catch (error) {
      _state = WalletSyncState.failed(error.toString());
      rethrow;
    }
  }
}
