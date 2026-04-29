class WalletBalance {
  static const int _satsPerBtc = 100000000;

  final int totalSats;
  final int spendableSats;
  final int immatureSats;
  final int trustedPendingSats;
  final int untrustedPendingSats;

  const WalletBalance({
    required this.totalSats,
    required this.spendableSats,
    this.immatureSats = 0,
    this.trustedPendingSats = 0,
    this.untrustedPendingSats = 0,
  }) : assert(totalSats >= 0, 'totalSats must be non-negative'),
       assert(spendableSats >= 0, 'spendableSats must be non-negative'),
       assert(immatureSats >= 0, 'immatureSats must be non-negative'),
       assert(
         trustedPendingSats >= 0,
         'trustedPendingSats must be non-negative',
       ),
       assert(
         untrustedPendingSats >= 0,
         'untrustedPendingSats must be non-negative',
       );

  bool get isEmpty => totalSats == 0;

  String get formattedSats => '$totalSats sats';

  String get formattedBtc {
    final whole = totalSats ~/ _satsPerBtc;
    final fraction = (totalSats % _satsPerBtc).toString().padLeft(8, '0');
    return '$whole.$fraction BTC';
  }
}
