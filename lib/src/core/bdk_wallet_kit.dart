import '../address/receive_address.dart';
import '../balance/wallet_balance.dart';
import '../bdk/bdk_dart_wallet_adapter.dart';
import '../bdk/bdk_wallet_adapter.dart';
import '../storage/wallet_storage.dart';
import '../sync/wallet_sync_state.dart';
import '../transactions/fee_rate_preset.dart';
import '../transactions/transaction_preview.dart';
import '../transactions/transaction_result.dart';
import 'created_wallet.dart';
import 'wallet_kit_config.dart';
import 'wallet_kit_exception.dart';

class BdkWalletKit {
  final WalletKitConfig config;
  final WalletStorage storage;
  final BdkWalletAdapter bdk;

  WalletSyncState _syncState = WalletSyncState.idle();
  bool _hasWallet = false;

  BdkWalletKit({
    required this.config,
    required this.storage,
    BdkWalletAdapter? bdkAdapter,
  }) : bdk = bdkAdapter ?? BdkDartWalletAdapter(config: config) {
    if (config.testnetOnly && config.network.isMainnet) {
      throw const WalletKitException(
        'Mainnet is disabled while testnetOnly is true.',
      );
    }
  }

  WalletSyncState get syncState => _syncState;

  Future<bool> initializeFromStorage() async {
    final mnemonic = await storage.readMnemonic();
    if (mnemonic == null || mnemonic.trim().isEmpty) {
      _hasWallet = false;
      return false;
    }

    await bdk.restoreWallet(mnemonic: mnemonic.trim());
    _hasWallet = true;
    return true;
  }

  Future<String> generateMnemonic() {
    return bdk.generateMnemonic();
  }

  Future<CreatedWallet> createNewWallet() async {
    final mnemonic = await generateMnemonic();
    await createWallet(mnemonic: mnemonic);
    return CreatedWallet(
      mnemonic: mnemonic,
      network: config.network,
      createdAt: DateTime.now(),
    );
  }

  Future<void> createWallet({required String mnemonic}) async {
    _validateMnemonic(mnemonic);
    final normalizedMnemonic = mnemonic.trim();

    await bdk.createWallet(mnemonic: normalizedMnemonic);
    await storage.saveMnemonic(normalizedMnemonic);
    _hasWallet = true;
  }

  Future<void> restoreWallet({required String mnemonic}) async {
    _validateMnemonic(mnemonic);
    final normalizedMnemonic = mnemonic.trim();

    await bdk.restoreWallet(mnemonic: normalizedMnemonic);
    await storage.saveMnemonic(normalizedMnemonic);
    _hasWallet = true;
  }

  Future<bool> hasWallet() {
    return storage.hasMnemonic();
  }

  Future<void> deleteWallet() async {
    await storage.deleteMnemonic();
    try {
      await bdk.reset();
    } finally {
      _hasWallet = false;
      _syncState = WalletSyncState.idle();
    }
  }

  Future<void> sync() async {
    _ensureWalletReady();
    _syncState = WalletSyncState.syncing();

    try {
      await bdk.sync();
      _syncState = WalletSyncState.synced();
    } catch (error) {
      _syncState = WalletSyncState.failed(error.toString());
      if (error is WalletKitException) {
        rethrow;
      }
      throw WalletKitException('Failed to sync wallet.', error);
    }
  }

  Future<WalletBalance> getBalance() {
    _ensureWalletReady();
    return bdk.getBalance();
  }

  Future<ReceiveAddress> getReceiveAddress() {
    _ensureWalletReady();
    return bdk.getReceiveAddress();
  }

  Future<TransactionPreview> previewSend({
    required String recipientAddress,
    required int amountSats,
    FeeRatePreset feeRatePreset = FeeRatePreset.normal,
  }) {
    _ensureWalletReady();
    return bdk.previewSend(
      recipientAddress: recipientAddress,
      amountSats: amountSats,
      feeRatePreset: feeRatePreset,
    );
  }

  Future<TransactionResult> send(TransactionPreview preview) {
    _ensureWalletReady();
    return bdk.send(preview);
  }

  void _validateMnemonic(String mnemonic) {
    if (mnemonic.trim().isEmpty) {
      throw const WalletKitException('Mnemonic cannot be empty.');
    }
  }

  void _ensureWalletReady() {
    if (!_hasWallet) {
      throw const WalletNotInitializedException();
    }
  }
}
