import '../core/wallet_kit_config.dart';

class BdkBlockchainAdapter {
  final WalletKitConfig config;

  const BdkBlockchainAdapter({required this.config});

  Future<void> connect() async {
    // TODO: Configure the bdk_dart Esplora blockchain backend here.
    // This adapter owns blockchain/backend wiring. Higher-level package code
    // should only depend on app-level models and state.
  }
}
