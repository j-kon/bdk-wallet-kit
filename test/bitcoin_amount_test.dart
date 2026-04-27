import 'package:bdk_wallet_kit/bdk_wallet_kit.dart';
import 'package:test/test.dart';

void main() {
  group('BitcoinAmount', () {
    test('stores sats as integers', () {
      const amount = BitcoinAmount.fromSats(123456789);

      expect(amount.sats, 123456789);
    });

    test('converts sats to BTC for display calculations', () {
      const amount = BitcoinAmount.fromSats(150000000);

      expect(amount.toBtc(), 1.5);
    });

    test('formats sats', () {
      const amount = BitcoinAmount.fromSats(2500);

      expect(amount.formatSats(), '2500 sats');
    });

    test('formats BTC with eight decimal places', () {
      const amount = BitcoinAmount.fromSats(123456789);

      expect(amount.formatBtc(), '1.23456789 BTC');
    });
  });
}
