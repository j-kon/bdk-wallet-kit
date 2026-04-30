import 'package:bdk_dart/bdk.dart' as bdk;

import '../address/receive_address.dart';
import '../balance/wallet_balance.dart';
import '../core/wallet_kit_exception.dart';
import '../core/wallet_kit_config.dart';
import '../transactions/fee_rate_preset.dart';
import '../transactions/transaction_preview.dart';
import '../transactions/transaction_result.dart';
import 'bdk_mapper.dart';
import 'bdk_wallet_adapter.dart';

class BdkDartWalletAdapter implements BdkWalletAdapter {
  @override
  final WalletKitConfig config;

  final int lookahead;
  final int parallelRequests;

  bdk.Wallet? _wallet;
  bdk.Persister? _persister;
  bdk.Psbt? _pendingSendPsbt;
  TransactionPreview? _pendingSendPreview;

  BdkDartWalletAdapter({
    required this.config,
    this.lookahead = 25,
    this.parallelRequests = 4,
  });

  @override
  Future<String> generateMnemonic() async {
    // bdk_dart owns mnemonic generation; this adapter returns only the phrase
    // string so public Flutter-facing APIs do not expose BDK types.
    final mnemonic = bdk.Mnemonic(wordCount: bdk.WordCount.words12);
    try {
      return mnemonic.toString();
    } finally {
      mnemonic.dispose();
    }
  }

  @override
  Future<void> createWallet({required String mnemonic}) async {
    await reset();
    _wallet = _buildWallet(mnemonic);
  }

  @override
  Future<void> restoreWallet({required String mnemonic}) async {
    await reset();
    _wallet = _buildWallet(mnemonic);
  }

  @override
  Future<void> reset() async {
    final wallet = _wallet;
    final persister = _persister;
    _clearPendingSend();
    _wallet = null;
    _persister = null;

    wallet?.dispose();
    persister?.dispose();
  }

  @override
  Future<void> sync() async {
    final wallet = _requireWallet();
    final persister = _requirePersister();
    final client = bdk.EsploraClient(url: config.esploraUrl, proxy: null);
    bdk.FullScanRequestBuilder? requestBuilder;
    bdk.FullScanRequest? request;
    bdk.Update? update;

    try {
      requestBuilder = wallet.startFullScan();
      request = requestBuilder.build();
      update = client.fullScan(
        request: request,
        stopGap: lookahead,
        parallelRequests: parallelRequests,
      );

      wallet.applyUpdate(update: update);
      wallet.persist(persister: persister);
    } finally {
      update?.dispose();
      request?.dispose();
      requestBuilder?.dispose();
      client.dispose();
    }
  }

  @override
  Future<WalletBalance> getBalance() async {
    final balance = _requireWallet().balance();

    return WalletBalance(
      totalSats: balance.total.toSat(),
      spendableSats: balance.trustedSpendable.toSat(),
      immatureSats: balance.immature.toSat(),
      trustedPendingSats: balance.trustedPending.toSat(),
      untrustedPendingSats: balance.untrustedPending.toSat(),
    );
  }

  @override
  Future<ReceiveAddress> getReceiveAddress() async {
    final addressInfo = _requireWallet().revealNextAddress(
      keychain: bdk.KeychainKind.external_,
    );
    final persister = _requirePersister();
    _requireWallet().persist(persister: persister);

    return ReceiveAddress(
      address: addressInfo.address.toString(),
      network: config.network,
      index: addressInfo.index,
      generatedAt: DateTime.now(),
    );
  }

  @override
  Future<TransactionPreview> previewSend({
    required String recipientAddress,
    required int amountSats,
    FeeRatePreset feeRatePreset = FeeRatePreset.normal,
  }) async {
    _validateSendRequest(
      recipientAddress: recipientAddress,
      amountSats: amountSats,
      feeRatePreset: feeRatePreset,
    );

    bdk.Psbt? psbt;
    try {
      psbt = _buildSendPsbt(
        recipientAddress: recipientAddress,
        amountSats: amountSats,
        feeRatePreset: feeRatePreset,
      );
      final estimatedFeeSats = psbt.fee();
      final preview = TransactionPreview(
        recipientAddress: recipientAddress.trim(),
        amountSats: amountSats,
        estimatedFeeSats: estimatedFeeSats,
        totalSats: amountSats + estimatedFeeSats,
        feeRatePreset: feeRatePreset,
      );

      _clearPendingSend();
      _pendingSendPsbt = psbt;
      _pendingSendPreview = preview;
      psbt = null;

      return preview;
    } catch (error) {
      if (error is WalletKitException) {
        rethrow;
      }
      throw WalletKitException('Failed to preview BDK transaction.', error);
    } finally {
      psbt?.dispose();
    }
  }

  @override
  Future<TransactionResult> send(TransactionPreview preview) async {
    _validateSendRequest(
      recipientAddress: preview.recipientAddress,
      amountSats: preview.amountSats,
      feeRatePreset: preview.feeRatePreset,
    );

    bdk.Psbt? psbt;
    bdk.Transaction? transaction;
    bdk.Txid? txid;
    bdk.EsploraClient? client;

    try {
      if (!_matchesPendingPreview(preview)) {
        throw const WalletKitException(
          'Create a fresh transaction preview before sending.',
        );
      }

      final sendPsbt = _takePendingSendPsbt();
      psbt = sendPsbt;

      final wallet = _requireWallet();
      final signed = wallet.sign(psbt: sendPsbt, signOptions: null);
      if (!signed) {
        throw const WalletKitException(
          'BDK could not fully sign the transaction.',
        );
      }

      transaction = sendPsbt.extractTx();
      txid = transaction.computeTxid();
      client = bdk.EsploraClient(url: config.esploraUrl, proxy: null);
      client.broadcast(transaction: transaction);
      wallet.persist(persister: _requirePersister());

      return TransactionResult(
        txid: txid.toString(),
        broadcasted: true,
        createdAt: DateTime.now(),
      );
    } catch (error) {
      if (error is WalletKitException) {
        rethrow;
      }
      throw WalletKitException(
        'Failed to sign and broadcast BDK transaction.',
        error,
      );
    } finally {
      client?.dispose();
      txid?.dispose();
      transaction?.dispose();
      psbt?.dispose();
      _clearPendingSend();
    }
  }

  bdk.Psbt _buildSendPsbt({
    required String recipientAddress,
    required int amountSats,
    required FeeRatePreset feeRatePreset,
  }) {
    final wallet = _requireWallet();
    final network = BdkMapper.network(config.network);
    bdk.Address? address;
    bdk.Script? script;
    bdk.Amount? amount;
    bdk.FeeRate? feeRate;
    bdk.TxBuilder? builder;
    bdk.TxBuilder? recipientBuilder;
    bdk.TxBuilder? feeBuilder;

    try {
      address = bdk.Address(address: recipientAddress.trim(), network: network);
      if (!address.isValidForNetwork(network: network)) {
        throw WalletKitException(
          'Recipient address is not valid for ${config.network.displayName}.',
        );
      }

      script = address.scriptPubkey();
      amount = bdk.Amount.fromSat(satoshi: amountSats);
      feeRate = bdk.FeeRate.fromSatPerVb(
        satVb: _feeRateSatPerVb(feeRatePreset),
      );

      // bdk_dart owns coin selection, change output construction, fee
      // calculation, PSBT construction, signing, and broadcasting. This
      // toolkit only maps Flutter-friendly inputs and outputs around those
      // primitives.
      builder = bdk.TxBuilder();
      recipientBuilder = builder.addRecipient(script: script, amount: amount);
      feeBuilder = recipientBuilder.feeRate(feeRate: feeRate);

      return feeBuilder.finish(wallet: wallet);
    } finally {
      feeBuilder?.dispose();
      recipientBuilder?.dispose();
      builder?.dispose();
      feeRate?.dispose();
      amount?.dispose();
      script?.dispose();
      address?.dispose();
    }
  }

  int _feeRateSatPerVb(FeeRatePreset feeRatePreset) {
    return switch (feeRatePreset) {
      FeeRatePreset.slow => 1,
      FeeRatePreset.normal => 3,
      FeeRatePreset.fast => 5,
      FeeRatePreset.custom => throw const WalletKitException(
        'Custom fee rates require an explicit sat/vB value and are not wired yet.',
      ),
    };
  }

  void _validateSendRequest({
    required String recipientAddress,
    required int amountSats,
    required FeeRatePreset feeRatePreset,
  }) {
    _requireWallet();
    if (recipientAddress.trim().isEmpty) {
      throw const WalletKitException('Recipient address cannot be empty.');
    }
    if (amountSats <= 0) {
      throw const WalletKitException('Amount must be greater than zero sats.');
    }
    if (feeRatePreset == FeeRatePreset.custom) {
      _feeRateSatPerVb(feeRatePreset);
    }
  }

  bool _matchesPendingPreview(TransactionPreview preview) {
    final pendingPreview = _pendingSendPreview;
    return pendingPreview != null &&
        _pendingSendPsbt != null &&
        pendingPreview.recipientAddress == preview.recipientAddress &&
        pendingPreview.amountSats == preview.amountSats &&
        pendingPreview.estimatedFeeSats == preview.estimatedFeeSats &&
        pendingPreview.totalSats == preview.totalSats &&
        pendingPreview.feeRatePreset == preview.feeRatePreset &&
        pendingPreview.changeAddress == preview.changeAddress;
  }

  bdk.Psbt _takePendingSendPsbt() {
    final psbt = _pendingSendPsbt;
    if (psbt == null) {
      throw StateError('Pending PSBT is not available.');
    }
    _pendingSendPsbt = null;
    _pendingSendPreview = null;
    return psbt;
  }

  void _clearPendingSend() {
    final pendingPsbt = _pendingSendPsbt;
    _pendingSendPsbt = null;
    _pendingSendPreview = null;
    pendingPsbt?.dispose();
  }

  bdk.Wallet _buildWallet(String mnemonicPhrase) {
    final network = BdkMapper.network(config.network);
    final mnemonic = bdk.Mnemonic.fromString(mnemonic: mnemonicPhrase);
    bdk.DescriptorSecretKey? secretKey;
    bdk.Descriptor? descriptor;
    bdk.Descriptor? changeDescriptor;

    try {
      secretKey = bdk.DescriptorSecretKey(
        network: network,
        mnemonic: mnemonic,
        password: null,
      );

      descriptor = bdk.Descriptor.newBip84(
        secretKey: secretKey,
        keychainKind: bdk.KeychainKind.external_,
        network: network,
      );
      changeDescriptor = bdk.Descriptor.newBip84(
        secretKey: secretKey,
        keychainKind: bdk.KeychainKind.internal,
        network: network,
      );
      final persister = bdk.Persister.newInMemory();
      try {
        final wallet = bdk.Wallet(
          descriptor: descriptor,
          changeDescriptor: changeDescriptor,
          network: network,
          persister: persister,
          lookahead: lookahead,
        );

        _persister = persister;
        return wallet;
      } catch (_) {
        persister.dispose();
        rethrow;
      }
    } finally {
      changeDescriptor?.dispose();
      descriptor?.dispose();
      secretKey?.dispose();
      mnemonic.dispose();
    }
  }

  bdk.Wallet _requireWallet() {
    final wallet = _wallet;
    if (wallet == null) {
      throw StateError(
        'Create or restore a wallet before calling BDK methods.',
      );
    }
    return wallet;
  }

  bdk.Persister _requirePersister() {
    final persister = _persister;
    if (persister == null) {
      throw StateError('Wallet persister is not initialized.');
    }
    return persister;
  }
}
