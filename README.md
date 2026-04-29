# bdk_wallet_kit

A Flutter-first companion toolkit built on top of `bdk-dart` for developers building Bitcoin wallet apps with BDK.

`bdk_wallet_kit` is not a replacement for `bdk-dart`. It provides app-level helpers and reusable Flutter patterns around wallet setup, secure storage, sync state, balance loading, receive addresses, transaction previews, onboarding, and simple wallet UI components.

## Current Status

Early experimental foundation.

The package structure, storage layer, sync state, balance/address models, basic widgets, and example Flutter app are in place. Real wallet operations are intentionally isolated behind the BDK adapter.

## Why This Exists

BDK exposes powerful Bitcoin wallet primitives. Flutter apps also need repeated app-level pieces: secure mnemonic storage, testnet-first setup, sync state that UI can observe, balance and address presentation models, transaction preview flows, and small reusable widgets.

This package collects those Flutter-facing patterns without copying BDK internals or wrapping every BDK method.

## Relationship with bdk-dart

`bdk-dart` is the BDK binding layer for Dart and Flutter.

`bdk_wallet_kit` sits above it as a Flutter app toolkit. It uses `bdk-dart` for wallet operations and focuses on the repeated app-level patterns Flutter developers need when building real Bitcoin wallet apps.

Advanced wallet behavior, descriptor-level work, signing internals, and full BDK feature access should remain in `bdk-dart`.

`bdk_wallet_kit` currently uses `bdk-dart` through a Git dependency because `bdk-dart` is not yet published on pub.dev.

## What Belongs Here

- Flutter-friendly wallet setup flows.
- Secure storage abstractions and adapters.
- Sync state management for app UI.
- Balance and receive-address models.
- Transaction preview and result models.
- Testnet-first onboarding helpers.
- Small reusable Flutter widgets.
- Example Flutter app patterns.

## What Belongs in bdk-dart

- Descriptor and key management internals.
- Wallet database behavior.
- Sync engine implementation.
- Fee estimation primitives.
- Transaction building, signing, and broadcasting.
- Complete access to BDK wallet APIs.

## Basic Usage

```dart
import 'package:bdk_wallet_kit/bdk_wallet_kit.dart';

final kit = BdkWalletKit(
  config: WalletKitConfig.testnet(),
  storage: const SecureWalletStorage(),
);

await kit.createWallet(
  mnemonic: 'abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon about',
);

await kit.sync();
final balance = await kit.getBalance();
final address = await kit.getReceiveAddress();
```

BDK-specific types stay inside the adapter layer so the Flutter-facing package API remains focused on app-level wallet patterns.

## Widgets

```dart
WalletBalanceCard(
  balance: WalletBalance(totalSats: 50000, spendableSats: 50000),
);

ReceiveAddressCard(
  receiveAddress: receiveAddress,
);

SyncStatusBadge(
  state: kit.syncState,
);
```

## Example App

The `example/` app demonstrates:

- `WalletKitConfig.testnet()`
- `SecureWalletStorage`
- `WalletBalanceCard`
- `ReceiveAddressCard`
- `SyncStatusBadge`
- Safe UI messages for pending BDK integration

Run it with:

```bash
cd example
flutter run
```

## Roadmap

### Phase 1: Flutter Package Foundation

- Flutter package structure
- Public API exports
- Secure storage abstraction
- Sync state models
- Balance and receive address models
- Basic Flutter widgets
- Example Flutter app

### Phase 2: BDK-Dart Integration

- Wallet creation through `bdk-dart`
- Wallet restore through `bdk-dart`
- Esplora backend configuration
- Wallet sync
- Balance fetching
- Receive address generation

### Phase 3: Transaction Flow

- Fee estimation
- Transaction preview
- PSBT or transaction building through BDK
- Signing
- Broadcasting
- Transaction result mapping

### Phase 4: Developer Experience

- Riverpod example
- Testnet onboarding flow
- Error mapping for Flutter UI
- Documentation recipes
- Tracking issue for feedback and possible upstreaming into `bdk-dart`

## Contributing

Contributions are welcome while the scope is being shaped. Please keep this package focused on Flutter app-level wallet patterns.

Good contributions include tests, docs, adapters, widgets, examples, and focused helpers. Please avoid reimplementing Bitcoin wallet primitives, copying BDK internals, or turning this package into a broad wrapper around every `bdk-dart` method.
