import 'package:bdk_wallet_kit/bdk_wallet_kit.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('WalletKitConfig', () {
    test('creates testnet defaults', () {
      final config = WalletKitConfig.testnet();

      expect(config.network, WalletNetwork.testnet);
      expect(config.esploraUrl, 'https://blockstream.info/testnet/api');
      expect(config.testnetOnly, isTrue);
      expect(config.enableLogging, isFalse);
    });

    test('creates signet defaults', () {
      final config = WalletKitConfig.signet();

      expect(config.network, WalletNetwork.signet);
      expect(config.esploraUrl, 'https://mempool.space/signet/api');
      expect(config.testnetOnly, isTrue);
    });
  });
}
