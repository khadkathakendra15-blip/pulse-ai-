import 'package:flutter_test/flutter_test.dart';
import 'package:pulse_ai_app/main.dart';

void main() {
  testWidgets('Pulse AI boots into the onboarding welcome screen', (tester) async {
    await tester.pumpWidget(const PulseApp());
    await tester.pump();
    expect(find.text('Pulse AI'), findsOneWidget);
    expect(find.text('Your AI Health Companion'), findsOneWidget);
  });
}
