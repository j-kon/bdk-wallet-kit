import 'wallet_network.dart';

class WalletKitConfig {
  final WalletNetwork network;
  final String esploraUrl;
  final bool testnetOnly;
  final bool enableLogging;

  const WalletKitConfig({
    required this.network,
    required this.esploraUrl,
    this.testnetOnly = true,
    this.enableLogging = false,
  });

  factory WalletKitConfig.testnet() {
    return const WalletKitConfig(
      network: WalletNetwork.testnet,
      esploraUrl: 'https://blockstream.info/testnet/api',
      testnetOnly: true,
    );
  }

  factory WalletKitConfig.signet() {
    return const WalletKitConfig(
      network: WalletNetwork.signet,
      esploraUrl: 'https://mempool.space/signet/api',
      testnetOnly: true,
    );
  }
}
