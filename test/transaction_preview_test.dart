import 'package:bdk_wallet_kit/bdk_wallet_kit.dart';
import 'package:test/test.dart';

void main() {
  group('TransactionPreview', () {
    test('calculates total sats from amount and estimated fee', () {
      const preview = TransactionPreview(
        recipientAddress: 'tb1qexample',
        amountSats: 10000,
        estimatedFeeSats: 250,
        feeRatePreset: FeeRatePreset.normal,
      );

      expect(preview.totalSats, 10250);
    });
  });
}
