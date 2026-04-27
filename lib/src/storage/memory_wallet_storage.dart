import 'wallet_storage.dart';

class MemoryWalletStorage implements WalletStorage {
  String? _mnemonic;

  @override
  Future<void> saveMnemonic(String mnemonic) async {
    _mnemonic = mnemonic;
  }

  @override
  Future<String?> readMnemonic() async => _mnemonic;

  @override
  Future<void> deleteMnemonic() async {
    _mnemonic = null;
  }

  @override
  Future<bool> hasMnemonic() async => _mnemonic != null;
}
