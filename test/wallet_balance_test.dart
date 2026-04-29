import 'package:bdk_wallet_kit/bdk_wallet_kit.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('WalletBalance', () {
    test('identifies empty balances', () {
      const balance = WalletBalance(totalSats: 0, spendableSats: 0);

      expect(balance.isEmpty, isTrue);
    });

    test('formats sats and btc', () {
      const balance = WalletBalance(
        totalSats: 123456789,
        spendableSats: 100000000,
      );

      expect(balance.formattedSats, '123456789 sats');
      expect(balance.formattedBtc, '1.23456789 BTC');
    });
  });
}
