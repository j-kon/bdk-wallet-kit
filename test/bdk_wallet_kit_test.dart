import 'package:bdk_wallet_kit/bdk_wallet_kit.dart';
import 'package:bdk_wallet_kit/src/bdk/bdk_wallet_adapter.dart';
import 'package:flutter_test/flutter_test.dart';

class FakeBdkWalletAdapter extends BdkWalletAdapter {
  bool createCalled = false;
  bool restoreCalled = false;
  bool syncCalled = false;

  FakeBdkWalletAdapter({required super.config});

  @override
  Future<void> createWallet({required String mnemonic}) async {
    createCalled = true;
  }

  @override
  Future<void> restoreWallet({required String mnemonic}) async {
    restoreCalled = true;
  }

  @override
  Future<void> sync() async {
    syncCalled = true;
  }

  @override
  Future<WalletBalance> getBalance() async {
    return const WalletBalance(totalSats: 50000, spendableSats: 50000);
  }

  @override
  Future<ReceiveAddress> getReceiveAddress() async {
    return ReceiveAddress(
      address: 'tb1qexample',
      network: config.network,
      generatedAt: DateTime.utc(2026),
    );
  }
}

void main() {
  group('BdkWalletKit', () {
    test('createWallet stores mnemonic and calls adapter', () async {
      final config = WalletKitConfig.testnet();
      final storage = MemoryWalletStorage();
      final adapter = FakeBdkWalletAdapter(config: config);
      final kit = BdkWalletKit(
        config: config,
        storage: storage,
        bdkAdapter: adapter,
      );

      await kit.createWallet(mnemonic: 'abandon abandon abandon');

      expect(await storage.readMnemonic(), 'abandon abandon abandon');
      expect(adapter.createCalled, isTrue);
    });

    test('restoreWallet stores mnemonic and calls adapter', () async {
      final config = WalletKitConfig.testnet();
      final storage = MemoryWalletStorage();
      final adapter = FakeBdkWalletAdapter(config: config);
      final kit = BdkWalletKit(
        config: config,
        storage: storage,
        bdkAdapter: adapter,
      );

      await kit.restoreWallet(mnemonic: 'abandon abandon abandon');

      expect(await storage.readMnemonic(), 'abandon abandon abandon');
      expect(adapter.restoreCalled, isTrue);
    });

    test('sync updates state after adapter sync', () async {
      final config = WalletKitConfig.testnet();
      final adapter = FakeBdkWalletAdapter(config: config);
      final kit = BdkWalletKit(
        config: config,
        storage: MemoryWalletStorage(),
        bdkAdapter: adapter,
      );

      await kit.sync();

      expect(adapter.syncCalled, isTrue);
      expect(kit.syncState.status, WalletSyncStatus.synced);
      expect(kit.syncState.lastSyncedAt, isNotNull);
    });

    test('delegates balance and receive address loading', () async {
      final config = WalletKitConfig.testnet();
      final adapter = FakeBdkWalletAdapter(config: config);
      final kit = BdkWalletKit(
        config: config,
        storage: MemoryWalletStorage(),
        bdkAdapter: adapter,
      );

      final balance = await kit.getBalance();
      final address = await kit.getReceiveAddress();

      expect(balance.totalSats, 50000);
      expect(address.address, 'tb1qexample');
      expect(address.network, WalletNetwork.testnet);
    });
  });
}
