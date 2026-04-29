import 'package:flutter/material.dart';

import '../balance/wallet_balance.dart';

class WalletBalanceCard extends StatelessWidget {
  final WalletBalance balance;
  final String title;

  const WalletBalanceCard({
    super.key,
    required this.balance,
    this.title = 'Balance',
  });

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
            Text(title, style: textTheme.titleMedium),
            const SizedBox(height: 8),
            Text(balance.formattedBtc, style: textTheme.headlineSmall),
            const SizedBox(height: 4),
            Text(
              'Spendable: ${balance.spendableSats} sats',
              style: textTheme.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }
}
