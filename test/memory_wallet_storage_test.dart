import 'package:bdk_wallet_kit/bdk_wallet_kit.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('MemoryWalletStorage', () {
    test('saves, reads, checks, and deletes mnemonic', () async {
      final storage = MemoryWalletStorage();

      expect(await storage.hasMnemonic(), isFalse);
      expect(await storage.readMnemonic(), isNull);

      await storage.saveMnemonic(
        'letter advice cage absurd amount doctor acoustic avoid letter advice cage above',
      );

      expect(await storage.hasMnemonic(), isTrue);
      expect(
        await storage.readMnemonic(),
        'letter advice cage absurd amount doctor acoustic avoid letter advice cage above',
      );

      await storage.deleteMnemonic();

      expect(await storage.hasMnemonic(), isFalse);
      expect(await storage.readMnemonic(), isNull);
    });
  });
}
