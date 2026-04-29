import 'package:bdk_wallet_kit/bdk_wallet_kit.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('TransactionPreview', () {
    test('keeps explicit total sats', () {
      const preview = TransactionPreview(
        recipientAddress: 'tb1qexample',
        amountSats: 10000,
        estimatedFeeSats: 250,
        totalSats: 10250,
        feeRatePreset: FeeRatePreset.normal,
      );

      expect(preview.totalSats, 10250);
    });
  });
}
