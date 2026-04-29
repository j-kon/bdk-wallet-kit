import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:meta/meta.dart';

import 'wallet_storage.dart';

class SecureWalletStorage implements WalletStorage {
  static const String defaultMnemonicKey = 'bdk_wallet_kit.mnemonic';

  final FlutterSecureStorage secureStorage;
  final String mnemonicKey;

  const SecureWalletStorage({
    this.secureStorage = const FlutterSecureStorage(),
    this.mnemonicKey = defaultMnemonicKey,
  });

  @visibleForTesting
  String get key => mnemonicKey;

  @override
  Future<void> saveMnemonic(String mnemonic) {
    return secureStorage.write(key: mnemonicKey, value: mnemonic);
  }

  @override
  Future<String?> readMnemonic() {
    return secureStorage.read(key: mnemonicKey);
  }

  @override
  Future<void> deleteMnemonic() {
    return secureStorage.delete(key: mnemonicKey);
  }

  @override
  Future<bool> hasMnemonic() async {
    final mnemonic = await readMnemonic();
    return mnemonic != null && mnemonic.isNotEmpty;
  }
}
