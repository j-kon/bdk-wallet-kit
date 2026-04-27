enum WalletNetwork {
  bitcoin,
  testnet,
  signet,
  regtest;

  bool get isMainnet => this == WalletNetwork.bitcoin;

  bool get isTestnetLike => switch (this) {
        WalletNetwork.bitcoin => false,
        WalletNetwork.testnet ||
        WalletNetwork.signet ||
        WalletNetwork.regtest =>
          true,
      };

  String get displayName => switch (this) {
        WalletNetwork.bitcoin => 'Bitcoin',
        WalletNetwork.testnet => 'Testnet',
        WalletNetwork.signet => 'Signet',
        WalletNetwork.regtest => 'Regtest',
      };
}
