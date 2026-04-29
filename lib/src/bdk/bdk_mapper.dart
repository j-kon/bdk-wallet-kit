import 'package:bdk_dart/bdk.dart' as bdk;

import '../core/wallet_network.dart';

class BdkMapper {
  const BdkMapper._();

  static bdk.Network network(WalletNetwork network) {
    return switch (network) {
      WalletNetwork.bitcoin => bdk.Network.bitcoin,
      WalletNetwork.testnet => bdk.Network.testnet,
      WalletNetwork.signet => bdk.Network.signet,
      WalletNetwork.regtest => bdk.Network.regtest,
    };
  }

  static String networkName(WalletNetwork network) {
    return switch (network) {
      WalletNetwork.bitcoin => 'bitcoin',
      WalletNetwork.testnet => 'testnet',
      WalletNetwork.signet => 'signet',
      WalletNetwork.regtest => 'regtest',
    };
  }
}
