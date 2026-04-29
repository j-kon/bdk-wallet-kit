import '../core/wallet_kit_config.dart';
import '../core/wallet_network.dart';

class TestnetOnboardingHelper {
  const TestnetOnboardingHelper();

  List<WalletNetwork> get recommendedNetworks => const [
    WalletNetwork.testnet,
    WalletNetwork.signet,
    WalletNetwork.regtest,
  ];

  WalletKitConfig defaultConfig() => WalletKitConfig.testnet();

  bool supports(WalletNetwork network) => network.isTestnetLike;
}
