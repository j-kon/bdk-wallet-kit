import '../storage/wallet_storage.dart';
import '../transactions/fee_rate_preset.dart';
import '../transactions/transaction_preview.dart';
import '../transactions/transaction_result.dart';
import 'bdk_wallet_kit_base.dart';
import 'wallet_kit_config.dart';
import 'wallet_kit_exception.dart';
import 'wallet_sync_state.dart';

class BdkWalletKit implements BdkWalletKitBase {
  @override
  final WalletKitConfig config;

  final WalletStorage storage;

  WalletSyncState _syncState = const WalletSyncState.idle();
  bool _initialized = false;

  BdkWalletKit({
    required this.config,
    required this.storage,
  });

  @override
  WalletSyncState get syncState => _syncState;

  bool get isInitialized => _initialized;

  @override
  Future<void> initialize() async {
    if (config.testnetOnly && config.network.isMainnet) {
      throw const WalletKitException(
        'Mainnet is disabled while testnetOnly is true.',
      );
    }

    _initialized = true;
  }

  @override
  Future<void> createWallet() async {
    _ensureInitialized();

    // TODO: Generate keys/descriptors through bdk-dart or bdk_flutter.
    // Mnemonic generation and wallet construction belong to official BDK
    // bindings. This toolkit should provide the app-level flow around them.
    throw UnimplementedError('BDK wallet creation is not implemented yet.');
  }

  @override
  Future<void> restoreWallet(String mnemonic) async {
    _ensureInitialized();

    if (mnemonic.trim().isEmpty) {
      throw const WalletKitException('Mnemonic cannot be empty.');
    }

    // This storage write is intentionally the only behavior implemented here.
    // Actual descriptor recovery and wallet restoration will be delegated to
    // bdk-dart or bdk_flutter.
    await storage.saveMnemonic(mnemonic.trim());
  }

  @override
  Future<void> sync() async {
    _ensureInitialized();
    _syncState = const WalletSyncState.syncing();

    // TODO: Call BDK sync APIs and map progress/errors into WalletSyncState.
    _syncState =
        const WalletSyncState.failed('BDK sync is not implemented yet.');
    throw UnimplementedError('BDK sync is not implemented yet.');
  }

  @override
  Future<int> getBalanceSats() async {
    _ensureInitialized();

    // TODO: Fetch balance from BDK. Do not synthesize balances in this toolkit.
    throw UnimplementedError('BDK balance fetching is not implemented yet.');
  }

  @override
  Future<String> getReceiveAddress() async {
    _ensureInitialized();

    // TODO: Generate receive addresses through BDK wallet APIs.
    throw UnimplementedError(
      'BDK receive address generation is not implemented yet.',
    );
  }

  @override
  Future<TransactionPreview> previewSend({
    required String recipientAddress,
    required int amountSats,
    FeeRatePreset feeRatePreset = FeeRatePreset.normal,
  }) async {
    _ensureInitialized();

    // TODO: Build transaction previews from BDK fee estimation and PSBT data.
    // App-friendly preview models belong here; transaction construction belongs
    // in the BDK bindings.
    throw UnimplementedError('BDK transaction preview is not implemented yet.');
  }

  @override
  Future<TransactionResult> send(TransactionPreview preview) async {
    _ensureInitialized();

    // TODO: Sign and broadcast through BDK. This toolkit should only coordinate
    // app-level send flows and expose safe result models.
    throw UnimplementedError('BDK transaction sending is not implemented yet.');
  }

  void _ensureInitialized() {
    if (!_initialized) {
      throw const WalletKitException('BdkWalletKit has not been initialized.');
    }
  }
}
