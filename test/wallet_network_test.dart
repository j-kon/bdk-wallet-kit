import 'package:bdk_wallet_kit/bdk_wallet_kit.dart';
import 'package:test/test.dart';

void main() {
  group('WalletNetwork', () {
    test('identifies mainnet', () {
      expect(WalletNetwork.bitcoin.isMainnet, isTrue);
      expect(WalletNetwork.testnet.isMainnet, isFalse);
    });

    test('identifies testnet-like networks', () {
      expect(WalletNetwork.bitcoin.isTestnetLike, isFalse);
      expect(WalletNetwork.testnet.isTestnetLike, isTrue);
      expect(WalletNetwork.signet.isTestnetLike, isTrue);
      expect(WalletNetwork.regtest.isTestnetLike, isTrue);
    });

    test('provides display names', () {
      expect(WalletNetwork.bitcoin.displayName, 'Bitcoin');
      expect(WalletNetwork.testnet.displayName, 'Testnet');
      expect(WalletNetwork.signet.displayName, 'Signet');
      expect(WalletNetwork.regtest.displayName, 'Regtest');
    });
  });
}
