import 'package:bdk_wallet_kit/bdk_wallet_kit.dart';
import 'package:test/test.dart';

void main() {
  group('MemoryWalletStorage', () {
    test('saves, reads, checks, and deletes mnemonic', () async {
      final storage = MemoryWalletStorage();

      expect(await storage.hasMnemonic(), isFalse);
      expect(await storage.readMnemonic(), isNull);

      await storage.saveMnemonic('abandon abandon abandon');

      expect(await storage.hasMnemonic(), isTrue);
      expect(await storage.readMnemonic(), 'abandon abandon abandon');

      await storage.deleteMnemonic();

      expect(await storage.hasMnemonic(), isFalse);
      expect(await storage.readMnemonic(), isNull);
    });
  });
}
