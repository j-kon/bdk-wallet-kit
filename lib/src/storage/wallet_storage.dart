abstract class WalletStorage {
  Future<void> saveMnemonic(String mnemonic);

  Future<String?> readMnemonic();

  Future<void> deleteMnemonic();

  Future<bool> hasMnemonic();
}
