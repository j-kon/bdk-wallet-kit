import '../address/receive_address.dart';
import '../balance/wallet_balance.dart';
import '../bdk/bdk_wallet_adapter.dart';
import '../storage/wallet_storage.dart';
import '../sync/wallet_sync_state.dart';
import '../transactions/fee_rate_preset.dart';
import '../transactions/transaction_preview.dart';
import '../transactions/transaction_result.dart';
import 'wallet_kit_config.dart';
import 'wallet_kit_exception.dart';

class BdkWalletKit {
  final WalletKitConfig config;
  final WalletStorage storage;
  final BdkWalletAdapter bdk;

  WalletSyncState _syncState = WalletSyncState.idle();

  BdkWalletKit({
    required this.config,
    required this.storage,
    BdkWalletAdapter? bdkAdapter,
  }) : bdk = bdkAdapter ?? PendingBdkWalletAdapter(config: config) {
    if (config.testnetOnly && config.network.isMainnet) {
      throw const WalletKitException(
        'Mainnet is disabled while testnetOnly is true.',
      );
    }
  }

  WalletSyncState get syncState => _syncState;

  Future<void> createWallet({
    required String mnemonic,
  }) async {
    _validateMnemonic(mnemonic);
    await storage.saveMnemonic(mnemonic.trim());
    await bdk.createWallet(mnemonic: mnemonic.trim());
  }

  Future<void> restoreWallet({
    required String mnemonic,
  }) async {
    _validateMnemonic(mnemonic);
    await storage.saveMnemonic(mnemonic.trim());
    await bdk.restoreWallet(mnemonic: mnemonic.trim());
  }

  Future<void> sync() async {
    _syncState = WalletSyncState.syncing();

    try {
      await bdk.sync();
      _syncState = WalletSyncState.synced();
    } catch (error) {
      _syncState = WalletSyncState.failed(error.toString());
      rethrow;
    }
  }

  Future<WalletBalance> getBalance() {
    return bdk.getBalance();
  }

  Future<ReceiveAddress> getReceiveAddress() {
    return bdk.getReceiveAddress();
  }

  Future<TransactionPreview> previewSend({
    required String recipientAddress,
    required int amountSats,
    FeeRatePreset feeRatePreset = FeeRatePreset.normal,
  }) {
    return bdk.previewSend(
      recipientAddress: recipientAddress,
      amountSats: amountSats,
      feeRatePreset: feeRatePreset,
    );
  }

  Future<TransactionResult> send(TransactionPreview preview) {
    return bdk.send(preview);
  }

  void _validateMnemonic(String mnemonic) {
    if (mnemonic.trim().isEmpty) {
      throw const WalletKitException('Mnemonic cannot be empty.');
    }
  }
}
