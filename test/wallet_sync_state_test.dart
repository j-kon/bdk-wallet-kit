import 'package:bdk_wallet_kit/bdk_wallet_kit.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('WalletSyncState', () {
    test('creates idle state', () {
      final state = WalletSyncState.idle();

      expect(state.status, WalletSyncStatus.idle);
      expect(state.lastSyncedAt, isNull);
      expect(state.errorMessage, isNull);
    });

    test('creates syncing state', () {
      final state = WalletSyncState.syncing();

      expect(state.status, WalletSyncStatus.syncing);
      expect(state.lastSyncedAt, isNull);
      expect(state.errorMessage, isNull);
    });

    test('creates synced state', () {
      final state = WalletSyncState.synced();

      expect(state.status, WalletSyncStatus.synced);
      expect(state.lastSyncedAt, isNotNull);
      expect(state.errorMessage, isNull);
    });

    test('creates failed state', () {
      final state = WalletSyncState.failed('sync failed');

      expect(state.status, WalletSyncStatus.failed);
      expect(state.lastSyncedAt, isNull);
      expect(state.errorMessage, 'sync failed');
    });
  });
}
