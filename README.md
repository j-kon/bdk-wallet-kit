# bdk_wallet_kit

`bdk_wallet_kit` is a companion toolkit for Flutter developers building Bitcoin wallet apps with BDK. It provides app-level helpers and reusable patterns around wallet setup, storage, sync state, transaction preview, and onboarding.

It does not replace `bdk-dart` or `bdk_flutter`. Advanced wallet operations should still use the official BDK bindings directly.

## Why This Exists

BDK gives Dart and Flutter developers access to powerful Bitcoin wallet primitives. Real wallet apps also need application-level patterns around configuration, secure storage, onboarding, sync state, transaction previews, error handling, and examples.

This package focuses on those app-level helpers and safe defaults. It should not become a competing implementation of BDK, a wrapper around every BDK method, or a place for advanced wallet behavior that belongs in `bdk-dart` or `bdk_flutter`.

## Current Status

Early experimental foundation.

The package currently includes lightweight models, storage abstractions, and placeholders for future BDK integration. It does not create real wallets, sync wallets, estimate fees, generate receive addresses, sign transactions, or broadcast transactions yet.

## Planned Features

- Wallet setup helpers for app onboarding flows.
- Secure storage adapters for Flutter apps.
- Sync state models for Flutter UI.
- Transaction preview models built from real BDK data.
- Testnet and signet onboarding helpers.
- Developer-friendly examples.
- Community discussion around helpers that may eventually belong upstream in `bdk-dart`.

## Basic Usage

```dart
import 'package:bdk_wallet_kit/bdk_wallet_kit.dart';

Future<void> main() async {
  final kit = BdkWalletKit(
    config: const WalletKitConfig(
      network: WalletNetwork.testnet,
    ),
    storage: MemoryWalletStorage(),
  );

  await kit.initialize();

  await kit.restoreWallet('abandon abandon abandon ...');

  final hasMnemonic = await kit.storage.hasMnemonic();
  print('Mnemonic stored: $hasMnemonic');
}
```

Real wallet operations are intentionally not implemented yet. Future versions will delegate wallet creation, restore, sync, balance, address generation, and transaction construction to `bdk-dart` or `bdk_flutter`.

## Roadmap

### Phase 1: Foundation

- Package structure
- Storage abstraction
- Config models
- Sync state models
- Transaction preview models
- Bitcoin amount utilities

### Phase 2: BDK Integration

- Wallet creation
- Wallet restore
- Esplora configuration
- Balance fetching
- Receive address generation
- Sync integration

### Phase 3: App-Level Helpers

- Transaction preview
- Fee presets
- Testnet onboarding helpers
- Error mapping for Flutter UI

### Phase 4: Developer Experience

- Example Flutter app
- Riverpod examples
- Documentation
- Tracking issue for possible upstreaming into `bdk-dart`

## Contributing

Contributions are welcome while the scope is still being shaped. Please keep changes aligned with the package goal: app-level helpers for Flutter wallet apps using BDK.

Good contributions include tests, documentation, focused helpers, examples, and careful integration points with official BDK bindings.

Please avoid adding broad BDK wrappers, fake wallet behavior, or advanced wallet logic that belongs in `bdk-dart` or `bdk_flutter`.
