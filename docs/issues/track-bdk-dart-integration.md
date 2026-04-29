# Track bdk-dart Integration

## Summary

`bdk_wallet_kit` is a Flutter-first companion toolkit for developers building Bitcoin wallet apps with BDK. It provides app-level helpers, safe defaults, storage abstractions, sync state models, transaction preview models, onboarding helpers, and small reusable Flutter widgets.

This package is not a replacement for `bdk-dart`. It should use `bdk-dart` as the wallet engine and keep direct BDK calls isolated inside the adapter layer.

## Why This Depends on bdk-dart

`bdk-dart` exposes the BDK wallet primitives for Dart and Flutter, including descriptor-based wallets, networks, addresses, blockchain clients, PSBTs, signing, and broadcasting.

`bdk_wallet_kit` sits above those primitives. It should not reimplement wallet internals, descriptor logic, signing logic, fee calculation, or blockchain sync engines. Instead, it should map app-level workflows onto the official `bdk-dart` APIs.

## BDK Operations to Wire First

- Wallet creation from mnemonic and descriptors.
- Wallet restore from mnemonic and descriptors.
- Esplora backend configuration.
- Wallet sync and sync error mapping.
- Balance loading and mapping into `WalletBalance`.
- Receive address generation and mapping into `ReceiveAddress`.
- Fee estimation for transaction previews.
- PSBT or transaction building through BDK.
- Signing through the BDK wallet.
- Broadcasting through the configured blockchain client.
- Transaction result mapping into `TransactionResult`.

## App-Level Features That Belong Here

- Flutter-friendly setup flows.
- Secure storage abstraction and storage adapters.
- Sync state models for UI.
- Balance and receive address presentation models.
- Transaction preview models.
- Testnet and signet onboarding helpers.
- Small reusable widgets for wallet UI.
- Example app patterns for Flutter developers.
- Error mapping that helps Flutter apps show useful messages.

These parts should remain focused on app ergonomics and should not become a full wrapper around every `bdk-dart` method.

## Possible Upstream Candidates

Some work may eventually be useful to upstream into `bdk-dart` as examples, documentation, or helper recipes:

- Minimal Flutter wallet setup examples.
- Descriptor creation recipes for common wallet types.
- Esplora sync examples.
- Transaction building and signing examples.
- Testnet/signet developer onboarding docs.
- Error mapping guidance for app developers.

## Adapter Boundary

Direct imports of `package:bdk_dart/bdk.dart` should stay inside `lib/src/bdk/`.

Public package APIs, widgets, storage classes, sync models, balance models, address models, and transaction models should remain free of direct BDK types.
