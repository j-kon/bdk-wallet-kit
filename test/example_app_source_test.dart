import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('example app does not use a hardcoded demo mnemonic', () {
    final source = File('example/lib/main.dart').readAsStringSync();

    expect(source, isNot(contains('abandon abandon')));
    expect(source, isNot(contains('BDK integration pending in adapter')));
    expect(source, isNot(contains('Action completed.')));
  });
}
