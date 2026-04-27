import '../transactions/fee_rate_preset.dart';
import '../transactions/transaction_preview.dart';
import '../transactions/transaction_result.dart';
import 'wallet_kit_config.dart';
import 'wallet_sync_state.dart';

abstract class BdkWalletKitBase {
  WalletKitConfig get config;

  WalletSyncState get syncState;

  Future<void> initialize();

  // Future BDK integration: create a descriptor-based wallet using bdk-dart or
  // bdk_flutter key management and wallet APIs. This toolkit should coordinate
  // app setup, not reimplement BDK wallet creation.
  Future<void> createWallet();

  // Future BDK integration: restore descriptors/wallet state through official
  // BDK bindings. This toolkit may provide storage and UX flow helpers.
  Future<void> restoreWallet(String mnemonic);

  // Future BDK integration: call official sync APIs and expose app-friendly
  // state for Flutter UI.
  Future<void> sync();

  // Future BDK integration: delegate balance calculation to BDK.
  Future<int> getBalanceSats();

  // Future BDK integration: delegate address generation to BDK.
  Future<String> getReceiveAddress();

  // Future BDK integration: build previews from BDK transaction construction
  // and fee estimation. Avoid fake fee or transaction behavior here.
  Future<TransactionPreview> previewSend({
    required String recipientAddress,
    required int amountSats,
    FeeRatePreset feeRatePreset = FeeRatePreset.normal,
  });

  // Future BDK integration: sign and optionally broadcast using BDK APIs.
  Future<TransactionResult> send(TransactionPreview preview);
}
