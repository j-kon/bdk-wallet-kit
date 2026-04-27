import 'wallet_network.dart';

class WalletKitConfig {
  final WalletNetwork network;
  final String? esploraUrl;
  final bool enableLogging;
  final bool testnetOnly;

  const WalletKitConfig({
    required this.network,
    this.esploraUrl,
    this.enableLogging = false,
    this.testnetOnly = true,
  });
}
