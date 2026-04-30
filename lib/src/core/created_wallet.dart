import 'wallet_network.dart';

class CreatedWallet {
  final String mnemonic;
  final WalletNetwork network;
  final DateTime createdAt;

  const CreatedWallet({
    required this.mnemonic,
    required this.network,
    required this.createdAt,
  });
}
