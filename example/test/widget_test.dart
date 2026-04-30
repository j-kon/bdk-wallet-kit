import 'package:bdk_wallet_kit/bdk_wallet_kit.dart';
import 'package:bdk_wallet_kit_example/main.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('shows wallet kit example controls', (tester) async {
    await tester.pumpWidget(
      BdkWalletKitExampleApp(storage: MemoryWalletStorage()),
    );
    await tester.pumpAndSettle();

    expect(find.text('bdk_wallet_kit'), findsOneWidget);
    expect(
      find.text('Testnet only. Do not use mainnet funds.'),
      findsOneWidget,
    );
    expect(find.text('Set up a testnet wallet'), findsOneWidget);
    expect(find.text('Create new testnet wallet'), findsOneWidget);
    expect(find.text('Restore existing testnet wallet'), findsOneWidget);
    expect(find.textContaining('abandon abandon'), findsNothing);
    expect(find.textContaining('BDK integration pending'), findsNothing);
    expect(find.textContaining('Action completed'), findsNothing);
  });
}
