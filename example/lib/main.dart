import 'package:bdk_wallet_kit/bdk_wallet_kit.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const BdkWalletKitExampleApp());
}

class BdkWalletKitExampleApp extends StatelessWidget {
  final WalletStorage? storage;

  const BdkWalletKitExampleApp({
    super.key,
    this.storage,
  });

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'bdk_wallet_kit',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xff0f766e),
          brightness: Brightness.light,
        ),
        useMaterial3: true,
      ),
      home: WalletKitExampleScreen(
        storage: storage ?? const SecureWalletStorage(),
      ),
    );
  }
}

class WalletKitExampleScreen extends StatefulWidget {
  final WalletStorage storage;

  const WalletKitExampleScreen({
    super.key,
    required this.storage,
  });

  @override
  State<WalletKitExampleScreen> createState() => _WalletKitExampleScreenState();
}

class _WalletKitExampleScreenState extends State<WalletKitExampleScreen> {
  static const _demoMnemonic =
      'abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon about';

  late final BdkWalletKit _kit;

  WalletBalance _balance = const WalletBalance(totalSats: 0, spendableSats: 0);
  ReceiveAddress? _receiveAddress;
  String _message = 'Ready for testnet setup.';

  @override
  void initState() {
    super.initState();
    _kit = BdkWalletKit(
      config: WalletKitConfig.testnet(),
      storage: widget.storage,
    );
  }

  Future<void> _runAction(Future<void> Function() action) async {
    try {
      await action();
      setState(() {
        _message = 'Action completed.';
      });
    } on UnimplementedError {
      setState(() {
        _message = 'BDK integration pending in adapter.';
      });
    } on Object catch (error) {
      setState(() {
        _message = error.toString();
      });
    }
  }

  Future<void> _createWallet() {
    return _runAction(() => _kit.createWallet(mnemonic: _demoMnemonic));
  }

  Future<void> _restoreWallet() {
    return _runAction(() => _kit.restoreWallet(mnemonic: _demoMnemonic));
  }

  Future<void> _syncWallet() {
    return _runAction(_kit.sync);
  }

  Future<void> _loadBalance() {
    return _runAction(() async {
      final balance = await _kit.getBalance();
      setState(() {
        _balance = balance;
      });
    });
  }

  Future<void> _getReceiveAddress() {
    return _runAction(() async {
      final address = await _kit.getReceiveAddress();
      setState(() {
        _receiveAddress = address;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('bdk_wallet_kit'),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: Center(child: SyncStatusBadge(state: _kit.syncState)),
          ),
        ],
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Text(
              'Testnet wallet toolkit',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text(
              'Flutter app patterns powered by BDK adapters.',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const SizedBox(height: 16),
            WalletBalanceCard(balance: _balance),
            const SizedBox(height: 12),
            ReceiveAddressCard(receiveAddress: _receiveAddress),
            const SizedBox(height: 12),
            Text(_message),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                FilledButton.icon(
                  onPressed: _createWallet,
                  icon: const Icon(Icons.add_circle_outline),
                  label: const Text('Create wallet'),
                ),
                FilledButton.icon(
                  onPressed: _restoreWallet,
                  icon: const Icon(Icons.restore_outlined),
                  label: const Text('Restore wallet'),
                ),
                OutlinedButton.icon(
                  onPressed: _syncWallet,
                  icon: const Icon(Icons.sync),
                  label: const Text('Sync wallet'),
                ),
                OutlinedButton.icon(
                  onPressed: _loadBalance,
                  icon: const Icon(Icons.account_balance_wallet_outlined),
                  label: const Text('Load balance'),
                ),
                OutlinedButton.icon(
                  onPressed: _getReceiveAddress,
                  icon: const Icon(Icons.call_received),
                  label: const Text('Receive address'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
