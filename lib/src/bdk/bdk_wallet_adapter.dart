import '../address/receive_address.dart';
import '../balance/wallet_balance.dart';
import '../core/wallet_kit_config.dart';

class BdkWalletAdapter {
  final WalletKitConfig config;

  BdkWalletAdapter({
    required this.config,
  });

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

  Future<void> restoreWallet({
    required String mnemonic,
  }) async {
    // TODO: Use bdk_dart descriptor/wallet restore APIs here.
    throw UnimplementedError('BDK wallet restore integration pending.');
  }

  Future<void> sync() async {
    // TODO: Use bdk_dart blockchain sync APIs here.
    throw UnimplementedError('BDK sync integration pending.');
  }

  Future<WalletBalance> getBalance() async {
    // TODO: Map bdk_dart balance result into WalletBalance.
    throw UnimplementedError('BDK balance integration pending.');
  }

  Future<ReceiveAddress> getReceiveAddress() async {
    // TODO: Use bdk_dart address generation.
    throw UnimplementedError('BDK receive address integration pending.');
  }
}
