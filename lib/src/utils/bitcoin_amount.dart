class BitcoinAmount {
  static const int satsPerBtc = 100000000;

  final int sats;

  const BitcoinAmount.fromSats(this.sats)
      : assert(sats >= 0, 'sats must be non-negative');

  double toBtc() => sats / satsPerBtc;

  String formatSats() => '$sats sats';

  String formatBtc() {
    final whole = sats ~/ satsPerBtc;
    final fraction = (sats % satsPerBtc).toString().padLeft(8, '0');
    return '$whole.$fraction BTC';
  }
}
