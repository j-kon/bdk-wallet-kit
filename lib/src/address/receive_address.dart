import '../core/wallet_network.dart';

class ReceiveAddress {
  final String address;
  final WalletNetwork network;
  final int? index;
  final DateTime generatedAt;

  const ReceiveAddress({
    required this.address,
    required this.network,
    this.index,
    required this.generatedAt,
  });
}
