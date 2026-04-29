import 'package:bdk_wallet_kit/bdk_wallet_kit.dart';
import 'package:bdk_wallet_kit_example/main.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('shows wallet kit example controls', (tester) async {
    await tester.pumpWidget(
      BdkWalletKitExampleApp(storage: MemoryWalletStorage()),
    );
    await tester.pump();

    expect(find.text('bdk_wallet_kit'), findsOneWidget);
    expect(find.text('Testnet wallet toolkit'), findsOneWidget);
    expect(find.text('Create wallet'), findsOneWidget);
    expect(find.text('Restore wallet'), findsOneWidget);
    expect(find.text('Sync wallet'), findsOneWidget);
    expect(find.text('Load balance'), findsOneWidget);
    expect(find.text('Receive address'), findsWidgets);
  });
}
