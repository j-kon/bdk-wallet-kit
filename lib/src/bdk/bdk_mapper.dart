import '../core/wallet_network.dart';

class BdkMapper {
  const BdkMapper._();

  static String networkName(WalletNetwork network) {
    // TODO: Replace this with a WalletNetwork -> bdk_dart Network mapper.
    // Keep that conversion here so BDK-specific types do not leak throughout
    // the Flutter-facing package API.
    return switch (network) {
      WalletNetwork.bitcoin => 'bitcoin',
      WalletNetwork.testnet => 'testnet',
      WalletNetwork.signet => 'signet',
      WalletNetwork.regtest => 'regtest',
    };
  }
}
