import '../address/receive_address.dart';
import '../balance/wallet_balance.dart';
import '../core/wallet_kit_config.dart';
import '../transactions/fee_rate_preset.dart';
import '../transactions/transaction_preview.dart';
import '../transactions/transaction_result.dart';

abstract class BdkWalletAdapter {
  WalletKitConfig get config;

  Future<void> createWallet({
    required String mnemonic,
  });

  Future<void> restoreWallet({
    required String mnemonic,
  });

  Future<void> sync();

  Future<WalletBalance> getBalance();

  Future<ReceiveAddress> getReceiveAddress();

  Future<TransactionPreview> previewSend({
    required String recipientAddress,
    required int amountSats,
    FeeRatePreset feeRatePreset = FeeRatePreset.normal,
  });

  Future<TransactionResult> send(TransactionPreview preview);
}

class PendingBdkWalletAdapter implements BdkWalletAdapter {
  @override
  final WalletKitConfig config;

  const PendingBdkWalletAdapter({
    required this.config,
  });

  @override
  Future<void> createWallet({
    required String mnemonic,
  }) async {
    // TODO: Use bdk_dart wallet creation APIs here.
    // Expected future work:
    // - map WalletNetwork through BdkMapper
    // - derive descriptors using bdk_dart key APIs
    // - create a BDK wallet with an Esplora-backed blockchain
    throw UnimplementedError('BDK wallet creation integration pending.');
  }

  @override
  Future<void> restoreWallet({
    required String mnemonic,
  }) async {
    // TODO: Use bdk_dart descriptor/wallet restore APIs here.
    throw UnimplementedError('BDK wallet restore integration pending.');
  }

  @override
  Future<void> sync() async {
    // TODO: Use bdk_dart blockchain sync APIs here.
    throw UnimplementedError('BDK sync integration pending.');
  }

  @override
  Future<WalletBalance> getBalance() async {
    // TODO: Map bdk_dart balance result into WalletBalance.
    throw UnimplementedError('BDK balance integration pending.');
  }

  @override
  Future<ReceiveAddress> getReceiveAddress() async {
    // TODO: Use bdk_dart address generation.
    throw UnimplementedError('BDK receive address integration pending.');
  }

  @override
  Future<TransactionPreview> previewSend({
    required String recipientAddress,
    required int amountSats,
    FeeRatePreset feeRatePreset = FeeRatePreset.normal,
  }) async {
    // TODO: Estimate fees and construct the preview from bdk_dart transaction
    // building APIs. Returning a zero-fee preview would be misleading.
    throw UnimplementedError('BDK fee estimation integration pending.');
  }

  @override
  Future<TransactionResult> send(TransactionPreview preview) async {
    // TODO: Build, sign, and broadcast through bdk_dart.
    throw UnimplementedError('BDK transaction sending integration pending.');
  }
}
