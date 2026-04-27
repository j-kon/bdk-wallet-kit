import 'package:bdk_wallet_kit/bdk_wallet_kit.dart';
import 'package:test/test.dart';

void main() {
  group('WalletSyncState', () {
    test('creates idle state', () {
      const state = WalletSyncState.idle();

      expect(state.status, WalletSyncStatus.idle);
      expect(state.lastSyncedAt, isNull);
      expect(state.errorMessage, isNull);
    });

    test('creates syncing state', () {
      const state = WalletSyncState.syncing();

      expect(state.status, WalletSyncStatus.syncing);
      expect(state.lastSyncedAt, isNull);
      expect(state.errorMessage, isNull);
    });

    test('creates synced state', () {
      final before = DateTime.now();
      final state = WalletSyncState.synced();
      final after = DateTime.now();

      expect(state.status, WalletSyncStatus.synced);
      expect(state.lastSyncedAt, isNotNull);
      expect(state.lastSyncedAt!.isBefore(before), isFalse);
      expect(state.lastSyncedAt!.isAfter(after), isFalse);
      expect(state.errorMessage, isNull);
    });

    test('creates failed state', () {
      const state = WalletSyncState.failed('sync failed');

      expect(state.status, WalletSyncStatus.failed);
      expect(state.lastSyncedAt, isNull);
      expect(state.errorMessage, 'sync failed');
    });
  });
}
