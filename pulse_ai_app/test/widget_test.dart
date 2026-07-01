import 'package:flutter_test/flutter_test.dart';
import 'package:pulse_ai_app/main.dart';

void main() {
  testWidgets('Pulse AI boots and shows the bottom nav', (tester) async {
    await tester.pumpWidget(const PulseApp());
    await tester.pump();
    expect(find.text('Today'), findsOneWidget);
    expect(find.text('Coach'), findsOneWidget);
  });
}
