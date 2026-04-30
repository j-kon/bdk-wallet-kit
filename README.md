# bdk_wallet_kit

A Flutter-first companion toolkit built on top of `bdk-dart` for developers building Bitcoin wallet apps with BDK.

`bdk_wallet_kit` is not a replacement for `bdk-dart`. It provides app-level helpers and reusable Flutter patterns around wallet setup, secure storage, sync state, balance loading, receive addresses, transaction previews, onboarding, and simple wallet UI components.

## Current Status

`bdk_wallet_kit` is currently focused on real testnet/signet wallet flows.

This package is experimental and should be used on testnet/signet while the BDK integration is being developed.

The package is being developed around:

- real wallet creation/restoration through `bdk-dart`
- secure mnemonic storage
- restoring wallet state from device storage
- syncing through a configured backend
- loading real wallet balance
- generating real receive addresses
- previewing real BDK-built transactions before broadcast
- signing and broadcasting transactions through `bdk-dart`

Transaction sending is early and testnet-focused. Review previews carefully and do not use mainnet funds.

## Prerequisites

Because `bdk-dart` uses Dart Native Assets, you need:

- Dart SDK >= 3.10
- Flutter SDK
- Rust toolchain with Cargo

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

final createdWallet = await kit.createNewWallet();
// Show `createdWallet.mnemonic` once so the user can back it up.

await kit.sync();
final balance = await kit.getBalance();
final address = await kit.getReceiveAddress();

final preview = await kit.previewSend(
  recipientAddress: testnetRecipientAddress,
  amountSats: 10_000,
);
final result = await kit.send(preview);
```

BDK-specific types stay inside the adapter layer so the Flutter-facing package API remains focused on app-level wallet patterns.

## Widgets

```dart
WalletBalanceCard(
  balance: balance,
);

ReceiveAddressCard(
  receiveAddress: receiveAddress,
);

SyncStatusBadge(
  state: kit.syncState,
);
```

## Example App

The `example/` app is a real testnet wallet example built on top of `bdk_wallet_kit` and `bdk-dart`.

The example app is not a mock demo. It is intended to be a real testnet wallet example using `bdk_wallet_kit` and `bdk-dart`.

It demonstrates:

- creating or restoring a testnet wallet
- secure mnemonic storage
- restoring wallet state from storage on app startup
- syncing through the configured Esplora backend
- loading real testnet balance
- generating real testnet receive addresses
- previewing real testnet sends with BDK fee calculation
- signing and broadcasting real testnet transactions
- showing wallet state with reusable Flutter widgets

Send support is testnet-first and uses the adapter layer for BDK transaction building, signing, and broadcasting.

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
