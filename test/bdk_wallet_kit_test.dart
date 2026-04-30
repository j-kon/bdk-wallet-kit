import 'package:bdk_wallet_kit/bdk_wallet_kit.dart';
import 'package:bdk_wallet_kit/src/bdk/bdk_wallet_adapter.dart';
import 'package:flutter_test/flutter_test.dart';

class FakeBdkWalletAdapter extends BdkWalletAdapter {
  @override
  final WalletKitConfig config;

  bool createCalled = false;
  bool restoreCalled = false;
  bool syncCalled = false;
  bool failSync = false;
  bool resetCalled = false;
  bool sendCalled = false;
  String? createdMnemonic;
  String? restoredMnemonic;
  TransactionPreview? sentPreview;

  FakeBdkWalletAdapter({required this.config});

  @override
  Future<String> generateMnemonic() async {
    return 'legal winner thank year wave sausage worth useful legal winner thank yellow';
  }

  @override
  Future<void> createWallet({required String mnemonic}) async {
    createCalled = true;
    createdMnemonic = mnemonic;
  }

  @override
  Future<void> restoreWallet({required String mnemonic}) async {
    restoreCalled = true;
    restoredMnemonic = mnemonic;
  }

  @override
  Future<void> reset() async {
    resetCalled = true;
  }

  @override
  Future<void> sync() async {
    syncCalled = true;
    if (failSync) {
      throw StateError('sync failed');
    }
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

  @override
  Future<TransactionPreview> previewSend({
    required String recipientAddress,
    required int amountSats,
    FeeRatePreset feeRatePreset = FeeRatePreset.normal,
  }) async {
    return TransactionPreview(
      recipientAddress: recipientAddress,
      amountSats: amountSats,
      estimatedFeeSats: 1000,
      totalSats: amountSats + 1000,
      feeRatePreset: feeRatePreset,
    );
  }

  @override
  Future<TransactionResult> send(TransactionPreview preview) async {
    sendCalled = true;
    sentPreview = preview;
    return TransactionResult(
      txid: '4d3c2b1a',
      broadcasted: true,
      createdAt: DateTime.utc(2026),
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

      await kit.createWallet(
        mnemonic:
            'letter advice cage absurd amount doctor acoustic avoid letter advice cage above',
      );

      expect(
        await storage.readMnemonic(),
        'letter advice cage absurd amount doctor acoustic avoid letter advice cage above',
      );
      expect(adapter.createCalled, isTrue);
      expect(
        adapter.createdMnemonic,
        'letter advice cage absurd amount doctor acoustic avoid letter advice cage above',
      );
      expect(await kit.hasWallet(), isTrue);
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

      await kit.restoreWallet(
        mnemonic:
            'letter advice cage absurd amount doctor acoustic avoid letter advice cage above',
      );

      expect(
        await storage.readMnemonic(),
        'letter advice cage absurd amount doctor acoustic avoid letter advice cage above',
      );
      expect(adapter.restoreCalled, isTrue);
      expect(
        adapter.restoredMnemonic,
        'letter advice cage absurd amount doctor acoustic avoid letter advice cage above',
      );
      expect(await kit.hasWallet(), isTrue);
    });

    test('initializeFromStorage restores wallet when mnemonic exists', () async {
      final config = WalletKitConfig.testnet();
      final storage = MemoryWalletStorage();
      final adapter = FakeBdkWalletAdapter(config: config);
      final kit = BdkWalletKit(
        config: config,
        storage: storage,
        bdkAdapter: adapter,
      );

      await storage.saveMnemonic(
        'letter advice cage absurd amount doctor acoustic avoid letter advice cage above',
      );

      final restored = await kit.initializeFromStorage();

      expect(restored, isTrue);
      expect(adapter.restoreCalled, isTrue);
      expect(
        adapter.restoredMnemonic,
        'letter advice cage absurd amount doctor acoustic avoid letter advice cage above',
      );
      expect(await kit.hasWallet(), isTrue);
    });

    test(
      'initializeFromStorage returns false when no mnemonic exists',
      () async {
        final config = WalletKitConfig.testnet();
        final adapter = FakeBdkWalletAdapter(config: config);
        final kit = BdkWalletKit(
          config: config,
          storage: MemoryWalletStorage(),
          bdkAdapter: adapter,
        );

        final restored = await kit.initializeFromStorage();

        expect(restored, isFalse);
        expect(adapter.restoreCalled, isFalse);
        expect(await kit.hasWallet(), isFalse);
      },
    );

    test('createNewWallet generates, creates, and stores mnemonic', () async {
      final config = WalletKitConfig.testnet();
      final storage = MemoryWalletStorage();
      final adapter = FakeBdkWalletAdapter(config: config);
      final kit = BdkWalletKit(
        config: config,
        storage: storage,
        bdkAdapter: adapter,
      );

      final createdWallet = await kit.createNewWallet();

      expect(
        createdWallet.mnemonic,
        'legal winner thank year wave sausage worth useful legal winner thank yellow',
      );
      expect(createdWallet.network, WalletNetwork.testnet);
      expect(createdWallet.createdAt, isNotNull);
      expect(adapter.createCalled, isTrue);
      expect(adapter.createdMnemonic, createdWallet.mnemonic);
      expect(await storage.readMnemonic(), createdWallet.mnemonic);
      expect(await kit.hasWallet(), isTrue);
    });

    test('deleteWallet clears storage and resets adapter state', () async {
      final config = WalletKitConfig.testnet();
      final storage = MemoryWalletStorage();
      final adapter = FakeBdkWalletAdapter(config: config);
      final kit = BdkWalletKit(
        config: config,
        storage: storage,
        bdkAdapter: adapter,
      );

      await kit.createWallet(
        mnemonic:
            'letter advice cage absurd amount doctor acoustic avoid letter advice cage above',
      );
      await kit.deleteWallet();

      expect(await storage.hasMnemonic(), isFalse);
      expect(await kit.hasWallet(), isFalse);
      expect(adapter.resetCalled, isTrue);
      expect(kit.syncState.status, WalletSyncStatus.idle);
    });

    test('sync updates state after adapter sync', () async {
      final config = WalletKitConfig.testnet();
      final adapter = FakeBdkWalletAdapter(config: config);
      final kit = BdkWalletKit(
        config: config,
        storage: MemoryWalletStorage(),
        bdkAdapter: adapter,
      );

      await kit.createWallet(
        mnemonic:
            'letter advice cage absurd amount doctor acoustic avoid letter advice cage above',
      );
      await kit.sync();

      expect(adapter.syncCalled, isTrue);
      expect(kit.syncState.status, WalletSyncStatus.synced);
      expect(kit.syncState.lastSyncedAt, isNotNull);
    });

    test('sync updates state after adapter failure', () async {
      final config = WalletKitConfig.testnet();
      final adapter = FakeBdkWalletAdapter(config: config)..failSync = true;
      final kit = BdkWalletKit(
        config: config,
        storage: MemoryWalletStorage(),
        bdkAdapter: adapter,
      );

      await kit.createWallet(
        mnemonic:
            'letter advice cage absurd amount doctor acoustic avoid letter advice cage above',
      );

      await expectLater(kit.sync(), throwsA(isA<WalletKitException>()));

      expect(adapter.syncCalled, isTrue);
      expect(kit.syncState.status, WalletSyncStatus.failed);
      expect(kit.syncState.errorMessage, contains('sync failed'));
    });

    test('delegates balance and receive address loading', () async {
      final config = WalletKitConfig.testnet();
      final adapter = FakeBdkWalletAdapter(config: config);
      final kit = BdkWalletKit(
        config: config,
        storage: MemoryWalletStorage(),
        bdkAdapter: adapter,
      );

      await kit.createWallet(
        mnemonic:
            'letter advice cage absurd amount doctor acoustic avoid letter advice cage above',
      );
      final balance = await kit.getBalance();
      final address = await kit.getReceiveAddress();

      expect(balance.totalSats, 50000);
      expect(address.address, 'tb1qexample');
      expect(address.network, WalletNetwork.testnet);
    });

    test('delegates transaction previews to adapter', () async {
      final config = WalletKitConfig.testnet();
      final adapter = FakeBdkWalletAdapter(config: config);
      final kit = BdkWalletKit(
        config: config,
        storage: MemoryWalletStorage(),
        bdkAdapter: adapter,
      );

      await kit.createWallet(
        mnemonic:
            'letter advice cage absurd amount doctor acoustic avoid letter advice cage above',
      );
      final preview = await kit.previewSend(
        recipientAddress: 'tb1qexample',
        amountSats: 10000,
      );

      expect(preview.estimatedFeeSats, 1000);
      expect(preview.totalSats, 11000);
    });

    test('delegates transaction send to adapter', () async {
      final config = WalletKitConfig.testnet();
      final adapter = FakeBdkWalletAdapter(config: config);
      final kit = BdkWalletKit(
        config: config,
        storage: MemoryWalletStorage(),
        bdkAdapter: adapter,
      );

      await kit.createWallet(
        mnemonic:
            'letter advice cage absurd amount doctor acoustic avoid letter advice cage above',
      );
      final preview = await kit.previewSend(
        recipientAddress: 'tb1qexample',
        amountSats: 10000,
      );
      final result = await kit.send(preview);

      expect(adapter.sendCalled, isTrue);
      expect(adapter.sentPreview, same(preview));
      expect(result.broadcasted, isTrue);
      expect(result.txid, '4d3c2b1a');
    });

    test('wallet operations throw clearly before create or restore', () async {
      final config = WalletKitConfig.testnet();
      final adapter = FakeBdkWalletAdapter(config: config);
      final kit = BdkWalletKit(
        config: config,
        storage: MemoryWalletStorage(),
        bdkAdapter: adapter,
      );

      expect(
        kit.getBalance,
        throwsA(
          isA<WalletNotInitializedException>().having(
            (error) => error.message,
            'message',
            'Wallet is not initialized. Create or restore a wallet first.',
          ),
        ),
      );
      expect(
        kit.sync,
        throwsA(
          isA<WalletNotInitializedException>().having(
            (error) => error.message,
            'message',
            'Wallet is not initialized. Create or restore a wallet first.',
          ),
        ),
      );
      expect(
        kit.getReceiveAddress,
        throwsA(
          isA<WalletNotInitializedException>().having(
            (error) => error.message,
            'message',
            'Wallet is not initialized. Create or restore a wallet first.',
          ),
        ),
      );
      expect(
        () =>
            kit.previewSend(recipientAddress: 'tb1qexample', amountSats: 1000),
        throwsA(
          isA<WalletNotInitializedException>().having(
            (error) => error.message,
            'message',
            'Wallet is not initialized. Create or restore a wallet first.',
          ),
        ),
      );
      expect(
        () => kit.send(
          TransactionPreview(
            recipientAddress: 'tb1qexample',
            amountSats: 1000,
            estimatedFeeSats: 0,
            totalSats: 1000,
            feeRatePreset: FeeRatePreset.normal,
          ),
        ),
        throwsA(
          isA<WalletNotInitializedException>().having(
            (error) => error.message,
            'message',
            'Wallet is not initialized. Create or restore a wallet first.',
          ),
        ),
      );
    });
  });
}
