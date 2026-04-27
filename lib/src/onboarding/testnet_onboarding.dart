import '../wallet/wallet_network.dart';
import 'wallet_setup_step.dart';

class TestnetOnboarding {
  const TestnetOnboarding();

  List<WalletNetwork> get recommendedNetworks => const [
        WalletNetwork.testnet,
        WalletNetwork.signet,
        WalletNetwork.regtest,
      ];

  List<WalletSetupStep> get defaultSteps => const [
        WalletSetupStep.chooseNetwork,
        WalletSetupStep.createOrRestoreWallet,
        WalletSetupStep.secureBackup,
        WalletSetupStep.configureStorage,
        WalletSetupStep.ready,
      ];

  bool supports(WalletNetwork network) => network.isTestnetLike;
}
