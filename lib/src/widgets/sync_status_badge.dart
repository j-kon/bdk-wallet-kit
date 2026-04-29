import 'package:flutter/material.dart';

import '../sync/wallet_sync_state.dart';

class SyncStatusBadge extends StatelessWidget {
  final WalletSyncState state;

  const SyncStatusBadge({super.key, required this.state});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final (label, color) = switch (state.status) {
      WalletSyncStatus.idle => ('Idle', colorScheme.secondary),
      WalletSyncStatus.syncing => ('Syncing', colorScheme.primary),
      WalletSyncStatus.synced => ('Synced', Colors.green),
      WalletSyncStatus.failed => ('Failed', colorScheme.error),
    };

    return DecoratedBox(
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        border: Border.all(color: color),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        child: Text(
          label,
          style: Theme.of(context).textTheme.labelMedium?.copyWith(
            color: color,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
