import 'package:flutter/material.dart';

import '../address/receive_address.dart';

class ReceiveAddressCard extends StatelessWidget {
  final ReceiveAddress? receiveAddress;
  final String emptyLabel;

  const ReceiveAddressCard({
    super.key,
    required this.receiveAddress,
    this.emptyLabel = 'No receive address yet',
  });

  @override
  Widget build(BuildContext context) {
    final address = receiveAddress;
    final textTheme = Theme.of(context).textTheme;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Receive address', style: textTheme.titleMedium),
            const SizedBox(height: 8),
            SelectableText(
              address?.address ?? emptyLabel,
              style: textTheme.bodyMedium,
            ),
            if (address != null && address.index != null) ...[
              const SizedBox(height: 8),
              Text('Index: ${address.index}', style: textTheme.bodySmall),
            ],
          ],
        ),
      ),
    );
  }
}
