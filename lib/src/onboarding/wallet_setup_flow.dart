enum WalletSetupStep {
  chooseNetwork,
  createOrRestoreWallet,
  secureBackup,
  configureStorage,
  ready,
}

class WalletSetupFlow {
  final List<WalletSetupStep> steps;
  final int currentIndex;

  const WalletSetupFlow({
    this.steps = const [
      WalletSetupStep.chooseNetwork,
      WalletSetupStep.createOrRestoreWallet,
      WalletSetupStep.secureBackup,
      WalletSetupStep.configureStorage,
      WalletSetupStep.ready,
    ],
    this.currentIndex = 0,
  }) : assert(currentIndex >= 0, 'currentIndex must be non-negative');

  WalletSetupStep get currentStep => steps[currentIndex];

  bool get isComplete => currentStep == WalletSetupStep.ready;

  WalletSetupFlow advance() {
    if (currentIndex >= steps.length - 1) {
      return this;
    }

    return WalletSetupFlow(steps: steps, currentIndex: currentIndex + 1);
  }
}
