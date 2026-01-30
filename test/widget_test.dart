// Lytix Widget Tests

import 'package:flutter_test/flutter_test.dart';
import 'package:lytix/main.dart';

void main() {
  testWidgets('Lytix app loads successfully', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const LytixApp());

    // Verify the app starts (splash screen should be visible)
    expect(find.text('Lytix'), findsOneWidget);
  });
}
