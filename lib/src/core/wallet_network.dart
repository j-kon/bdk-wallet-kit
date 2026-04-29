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
    WalletNetwork.regtest => true,
  };

  String get displayName => switch (this) {
    WalletNetwork.bitcoin => 'Bitcoin',
    WalletNetwork.testnet => 'Testnet',
    WalletNetwork.signet => 'Signet',
    WalletNetwork.regtest => 'Regtest',
  };
}

// WalletNetwork maps to bdk_dart's Network enum inside the adapter layer so
// BDK-specific types do not leak into the public Flutter-facing API.
