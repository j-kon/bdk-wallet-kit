import '../wallet/wallet_kit_exception.dart';
import 'wallet_storage.dart';

class SecureWalletStorage implements WalletStorage {
  const SecureWalletStorage();

  Never _notConfigured() {
    // TODO: Wire this to a platform secure-storage implementation, such as
    // flutter_secure_storage, once this package is ready to take a Flutter
    // dependency or expose a separate Flutter adapter package.
    //
    // This toolkit should own app-level storage patterns. It should not own
    // BDK wallet internals, descriptor persistence, or database formats.
    throw const WalletKitException(
      'SecureWalletStorage is not configured yet. Provide a WalletStorage '
      'implementation or use MemoryWalletStorage for tests.',
    );
  }

  @override
  Future<void> saveMnemonic(String mnemonic) async => _notConfigured();

  @override
  Future<String?> readMnemonic() async => _notConfigured();

  @override
  Future<void> deleteMnemonic() async => _notConfigured();

  @override
  Future<bool> hasMnemonic() async => _notConfigured();
}
