import 'package:bdk_dart/bdk.dart' as bdk;

import '../address/receive_address.dart';
import '../balance/wallet_balance.dart';
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

  BdkDartWalletAdapter({
    required this.config,
    this.lookahead = 25,
    this.parallelRequests = 4,
  });

  @override
  Future<void> createWallet({required String mnemonic}) async {
    _wallet = _buildWallet(mnemonic);
  }

  @override
  Future<void> restoreWallet({required String mnemonic}) async {
    _wallet = _buildWallet(mnemonic);
  }

  @override
  Future<void> sync() async {
    final wallet = _requireWallet();
    final persister = _requirePersister();
    final client = bdk.EsploraClient(url: config.esploraUrl, proxy: null);

    final requestBuilder = wallet.startFullScan();
    final request = requestBuilder.build();
    final update = client.fullScan(
      request: request,
      stopGap: lookahead,
      parallelRequests: parallelRequests,
    );

    wallet.applyUpdate(update: update);
    wallet.persist(persister: persister);

    update.dispose();
    request.dispose();
    requestBuilder.dispose();
    client.dispose();
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
    // TODO: Use bdk.Address(address: ..., network: ...), Address.scriptPubkey(),
    // bdk.Amount.fromSat(), bdk.FeeRate.fromSatPerVb(), bdk.TxBuilder()
    // .addRecipient().feeRate().finish(wallet: ...), and bdk.Psbt.fee() to
    // build a real preview without broadcasting.
    throw UnimplementedError('BDK fee estimation integration pending.');
  }

  @override
  Future<TransactionResult> send(TransactionPreview preview) async {
    // TODO: Use bdk.TxBuilder to create a PSBT, wallet.sign(psbt: ...),
    // psbt.extractTx(), transaction.computeTxid(), and
    // bdk.EsploraClient.broadcast(transaction: ...) for the real send path.
    throw UnimplementedError('BDK transaction sending integration pending.');
  }

  bdk.Wallet _buildWallet(String mnemonicPhrase) {
    final network = BdkMapper.network(config.network);
    final mnemonic = bdk.Mnemonic.fromString(mnemonic: mnemonicPhrase);
    final secretKey = bdk.DescriptorSecretKey(
      network: network,
      mnemonic: mnemonic,
      password: null,
    );

    final descriptor = bdk.Descriptor.newBip84(
      secretKey: secretKey,
      keychainKind: bdk.KeychainKind.external_,
      network: network,
    );
    final changeDescriptor = bdk.Descriptor.newBip84(
      secretKey: secretKey,
      keychainKind: bdk.KeychainKind.internal,
      network: network,
    );
    final persister = bdk.Persister.newInMemory();
    final wallet = bdk.Wallet(
      descriptor: descriptor,
      changeDescriptor: changeDescriptor,
      network: network,
      persister: persister,
      lookahead: lookahead,
    );

    _persister = persister;
    return wallet;
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
