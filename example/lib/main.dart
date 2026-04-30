import 'package:bdk_wallet_kit/bdk_wallet_kit.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() {
  runApp(const BdkWalletKitExampleApp());
}

class BdkWalletKitExampleApp extends StatelessWidget {
  final WalletStorage? storage;

  const BdkWalletKitExampleApp({super.key, this.storage});

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

  const WalletKitExampleScreen({super.key, required this.storage});

  @override
  State<WalletKitExampleScreen> createState() => _WalletKitExampleScreenState();
}

class _WalletKitExampleScreenState extends State<WalletKitExampleScreen> {
  late final BdkWalletKit _kit;

  WalletBalance? _balance;
  ReceiveAddress? _receiveAddress;
  String _message = 'Checking secure wallet storage...';
  bool _isInitializing = true;
  bool _isBusy = false;
  bool _hasWallet = false;

  @override
  void initState() {
    super.initState();
    _kit = BdkWalletKit(
      config: WalletKitConfig.testnet(),
      storage: widget.storage,
    );
    _initializeWallet();
  }

  Future<void> _initializeWallet() async {
    try {
      final restored = await _kit.initializeFromStorage();
      if (!mounted) {
        return;
      }

      setState(() {
        _hasWallet = restored;
        _message = restored
            ? 'Wallet restored from secure storage.'
            : 'Create or restore a testnet wallet to begin.';
      });
    } on Object catch (error) {
      if (!mounted) {
        return;
      }

      setState(() {
        _message = 'Could not restore wallet from storage: $error';
      });
    } finally {
      if (mounted) {
        setState(() {
          _isInitializing = false;
        });
      }
    }
  }

  Future<void> _runWalletAction(Future<void> Function() action) async {
    setState(() {
      _isBusy = true;
    });

    try {
      await action();
    } on Object catch (error) {
      if (!mounted) {
        return;
      }
      setState(() {
        _message = error.toString();
      });
    } finally {
      if (mounted) {
        setState(() {
          _isBusy = false;
        });
      }
    }
  }

  Future<void> _createWallet() {
    return _runWalletAction(() async {
      final createdWallet = await _kit.createWallet();
      if (!mounted) {
        return;
      }

      setState(() {
        _hasWallet = true;
        _balance = null;
        _receiveAddress = null;
        _message = 'Wallet created. Back up your recovery phrase.';
      });

      await _showBackupDialog(createdWallet.mnemonic);
    });
  }

  Future<void> _restoreWallet(String mnemonic) {
    return _runWalletAction(() async {
      await _kit.restoreWallet(mnemonic: mnemonic);
      if (!mounted) {
        return;
      }

      setState(() {
        _hasWallet = true;
        _balance = null;
        _receiveAddress = null;
        _message = 'Wallet restored.';
      });
    });
  }

  Future<void> _syncWallet() {
    setState(() {
      _message = 'Syncing wallet...';
    });

    return _runWalletAction(() async {
      await _kit.sync();
      if (!mounted) {
        return;
      }

      setState(() {
        _message = 'Wallet synced.';
      });
    });
  }

  Future<void> _loadBalance() {
    return _runWalletAction(() async {
      final balance = await _kit.getBalance();
      if (!mounted) {
        return;
      }

      setState(() {
        _balance = balance;
        _message = 'Balance loaded.';
      });
    });
  }

  Future<void> _generateReceiveAddress() {
    return _runWalletAction(() async {
      final address = await _kit.getReceiveAddress();
      if (!mounted) {
        return;
      }

      setState(() {
        _receiveAddress = address;
        _message = 'Receive address generated.';
      });
    });
  }

  Future<void> _copyReceiveAddress() async {
    final address = _receiveAddress?.address;
    if (address == null) {
      setState(() {
        _message = 'Generate a receive address before copying.';
      });
      return;
    }

    await Clipboard.setData(ClipboardData(text: address));
    if (!mounted) {
      return;
    }

    setState(() {
      _message = 'Receive address copied.';
    });
  }

  Future<void> _deleteWallet() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => const _DeleteWalletDialog(),
    );

    if (confirmed != true) {
      return;
    }

    await _runWalletAction(() async {
      await _kit.deleteWallet();
      if (!mounted) {
        return;
      }

      setState(() {
        _hasWallet = false;
        _balance = null;
        _receiveAddress = null;
        _message = 'Wallet deleted from this device.';
      });
    });
  }

  Future<void> _showRestoreDialog() async {
    final mnemonic = await showDialog<String>(
      context: context,
      builder: (context) => const _RestoreWalletDialog(),
    );

    if (mnemonic == null) {
      return;
    }

    await _restoreWallet(mnemonic);
  }

  Future<void> _showBackupDialog(String mnemonic) {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (context) => _BackupMnemonicDialog(mnemonic: mnemonic),
    );
  }

  @override
  Widget build(BuildContext context) {
    final syncState = _kit.syncState;

    return Scaffold(
      appBar: AppBar(
        title: const Text('bdk_wallet_kit'),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: Center(child: SyncStatusBadge(state: syncState)),
          ),
        ],
      ),
      body: SafeArea(
        child: _isInitializing
            ? const Center(child: CircularProgressIndicator())
            : ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  const _NetworkWarning(),
                  const SizedBox(height: 16),
                  if (_hasWallet)
                    _WalletHomeSection(
                      balance: _balance,
                      receiveAddress: _receiveAddress,
                      message: _message,
                      isBusy: _isBusy,
                      syncState: syncState,
                      onSync: _syncWallet,
                      onLoadBalance: _loadBalance,
                      onGenerateReceiveAddress: _generateReceiveAddress,
                      onCopyReceiveAddress: _copyReceiveAddress,
                      onDeleteWallet: _deleteWallet,
                    )
                  else
                    _WalletSetupSection(
                      message: _message,
                      isBusy: _isBusy,
                      onCreateWallet: _createWallet,
                      onRestoreWallet: _showRestoreDialog,
                    ),
                ],
              ),
      ),
    );
  }
}

class _NetworkWarning extends StatelessWidget {
  const _NetworkWarning();

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: colorScheme.errorContainer,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(Icons.warning_amber_rounded, color: colorScheme.error),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                'Testnet only. Do not use mainnet funds.',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onErrorContainer,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _WalletSetupSection extends StatelessWidget {
  final String message;
  final bool isBusy;
  final VoidCallback onCreateWallet;
  final VoidCallback onRestoreWallet;

  const _WalletSetupSection({
    required this.message,
    required this.isBusy,
    required this.onCreateWallet,
    required this.onRestoreWallet,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Set up a testnet wallet', style: textTheme.headlineSmall),
        const SizedBox(height: 8),
        Text(
          'Create a new recovery phrase or restore an existing testnet wallet.',
          style: textTheme.bodyLarge,
        ),
        const SizedBox(height: 16),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                FilledButton.icon(
                  onPressed: isBusy ? null : onCreateWallet,
                  icon: const Icon(Icons.add_circle_outline),
                  label: const Text('Create new testnet wallet'),
                ),
                const SizedBox(height: 8),
                OutlinedButton.icon(
                  onPressed: isBusy ? null : onRestoreWallet,
                  icon: const Icon(Icons.restore_outlined),
                  label: const Text('Restore existing testnet wallet'),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),
        _StatusMessage(message: message, isBusy: isBusy),
      ],
    );
  }
}

class _WalletHomeSection extends StatelessWidget {
  final WalletBalance? balance;
  final ReceiveAddress? receiveAddress;
  final String message;
  final bool isBusy;
  final WalletSyncState syncState;
  final VoidCallback onSync;
  final VoidCallback onLoadBalance;
  final VoidCallback onGenerateReceiveAddress;
  final VoidCallback onCopyReceiveAddress;
  final VoidCallback onDeleteWallet;

  const _WalletHomeSection({
    required this.balance,
    required this.receiveAddress,
    required this.message,
    required this.isBusy,
    required this.syncState,
    required this.onSync,
    required this.onLoadBalance,
    required this.onGenerateReceiveAddress,
    required this.onCopyReceiveAddress,
    required this.onDeleteWallet,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text('Wallet home', style: textTheme.headlineSmall),
            const SizedBox(width: 12),
            const _NetworkBadge(),
          ],
        ),
        const SizedBox(height: 12),
        SyncStatusBadge(state: syncState),
        const SizedBox(height: 16),
        if (balance == null)
          const _EmptyBalanceCard()
        else
          WalletBalanceCard(balance: balance!),
        const SizedBox(height: 12),
        ReceiveAddressCard(receiveAddress: receiveAddress),
        const SizedBox(height: 12),
        _StatusMessage(message: message, isBusy: isBusy),
        const SizedBox(height: 16),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            OutlinedButton.icon(
              onPressed: isBusy ? null : onSync,
              icon: const Icon(Icons.sync),
              label: const Text('Sync wallet'),
            ),
            OutlinedButton.icon(
              onPressed: isBusy ? null : onLoadBalance,
              icon: const Icon(Icons.account_balance_wallet_outlined),
              label: const Text('Refresh balance'),
            ),
            OutlinedButton.icon(
              onPressed: isBusy ? null : onGenerateReceiveAddress,
              icon: const Icon(Icons.call_received),
              label: const Text('Generate receive address'),
            ),
            OutlinedButton.icon(
              onPressed: isBusy ? null : onCopyReceiveAddress,
              icon: const Icon(Icons.copy),
              label: const Text('Copy receive address'),
            ),
            OutlinedButton.icon(
              onPressed: isBusy ? null : onDeleteWallet,
              icon: const Icon(Icons.delete_outline),
              label: const Text('Delete wallet'),
            ),
          ],
        ),
        const SizedBox(height: 16),
        const _SendUnavailableCard(),
      ],
    );
  }
}

class _NetworkBadge extends StatelessWidget {
  const _NetworkBadge();

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: colorScheme.primaryContainer,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        child: Text(
          'Testnet',
          style: Theme.of(context).textTheme.labelMedium?.copyWith(
            color: colorScheme.onPrimaryContainer,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}

class _EmptyBalanceCard extends StatelessWidget {
  const _EmptyBalanceCard();

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Balance', style: textTheme.titleMedium),
            const SizedBox(height: 8),
            Text('Not loaded yet', style: textTheme.headlineSmall),
            const SizedBox(height: 4),
            Text('Sync, then load balance.', style: textTheme.bodyMedium),
          ],
        ),
      ),
    );
  }
}

class _SendUnavailableCard extends StatelessWidget {
  const _SendUnavailableCard();

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Text(
          'Send is coming later after real BDK transaction building, signing, and broadcasting are wired.',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
      ),
    );
  }
}

class _DeleteWalletDialog extends StatelessWidget {
  const _DeleteWalletDialog();

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Delete wallet from this device?'),
      content: const Text(
        'This removes the saved recovery phrase from secure storage. Only continue if you have backed it up.',
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: () => Navigator.of(context).pop(true),
          child: const Text('Delete wallet'),
        ),
      ],
    );
  }
}

class _StatusMessage extends StatelessWidget {
  final String message;
  final bool isBusy;

  const _StatusMessage({required this.message, required this.isBusy});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (isBusy) ...[
          const SizedBox(
            width: 18,
            height: 18,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
          const SizedBox(width: 8),
        ],
        Expanded(child: Text(message)),
      ],
    );
  }
}

class _RestoreWalletDialog extends StatefulWidget {
  const _RestoreWalletDialog();

  @override
  State<_RestoreWalletDialog> createState() => _RestoreWalletDialogState();
}

class _RestoreWalletDialogState extends State<_RestoreWalletDialog> {
  final _controller = TextEditingController();
  String? _errorText;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _restore() {
    final mnemonic = _controller.text.trim();
    if (mnemonic.isEmpty) {
      setState(() {
        _errorText = 'Enter a recovery phrase.';
      });
      return;
    }

    Navigator.of(context).pop(mnemonic);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Restore testnet wallet'),
      content: TextField(
        controller: _controller,
        minLines: 3,
        maxLines: 6,
        decoration: InputDecoration(
          labelText: 'Recovery phrase',
          errorText: _errorText,
          border: const OutlineInputBorder(),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        FilledButton(onPressed: _restore, child: const Text('Restore')),
      ],
    );
  }
}

class _BackupMnemonicDialog extends StatefulWidget {
  final String mnemonic;

  const _BackupMnemonicDialog({required this.mnemonic});

  @override
  State<_BackupMnemonicDialog> createState() => _BackupMnemonicDialogState();
}

class _BackupMnemonicDialogState extends State<_BackupMnemonicDialog> {
  bool _confirmed = false;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Back up recovery phrase'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Write this phrase down now. It will only be shown once.'),
          const SizedBox(height: 12),
          DecoratedBox(
            decoration: BoxDecoration(
              border: Border.all(color: Theme.of(context).dividerColor),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: SelectableText(widget.mnemonic),
            ),
          ),
          const SizedBox(height: 12),
          CheckboxListTile(
            contentPadding: EdgeInsets.zero,
            value: _confirmed,
            onChanged: (value) {
              setState(() {
                _confirmed = value ?? false;
              });
            },
            title: const Text('I have saved my recovery phrase.'),
          ),
        ],
      ),
      actions: [
        FilledButton(
          onPressed: _confirmed ? () => Navigator.of(context).pop() : null,
          child: const Text('Continue'),
        ),
      ],
    );
  }
}
