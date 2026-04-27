import 'fee_rate_preset.dart';

class TransactionPreview {
  final String recipientAddress;
  final int amountSats;
  final int estimatedFeeSats;
  final int totalSats;
  final FeeRatePreset feeRatePreset;
  final String? changeAddress;

  const TransactionPreview({
    required this.recipientAddress,
    required this.amountSats,
    required this.estimatedFeeSats,
    int? totalSats,
    required this.feeRatePreset,
    this.changeAddress,
  })  : assert(amountSats >= 0, 'amountSats must be non-negative'),
        assert(
          estimatedFeeSats >= 0,
          'estimatedFeeSats must be non-negative',
        ),
        totalSats = totalSats ?? amountSats + estimatedFeeSats;
}
