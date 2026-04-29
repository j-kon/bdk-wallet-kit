import 'bdk_wallet_adapter.dart';

class BdkDartWalletAdapter extends PendingBdkWalletAdapter {
  const BdkDartWalletAdapter({
    required super.config,
  });

  // TODO: Add `import 'package:bdk_dart/bdk.dart' as bdk;` once the project can
  // depend on bdk_dart with the active Flutter SDK.
  //
  // This is the intended home for all direct bdk_dart calls:
  // - bdk.Mnemonic / bdk.DescriptorSecretKey
  // - bdk.Descriptor.newBip84 or bdk.Descriptor.newBip86
  // - bdk.Persister and bdk.Wallet construction
  // - blockchain sync through the bdk_dart backend APIs
  // - balance and address mapping into Flutter-facing package models
  //
  // Keeping this adapter separate preserves the package boundary: app code uses
  // BdkWalletKit, while advanced wallet work still belongs in bdk_dart.
}
