import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:kekomo_flutter/app.dart';

void main() {
  testWidgets('App renders and shows navigation', (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: KeComoApp(),
      ),
    );
    await tester.pumpAndSettle();
  });
}
