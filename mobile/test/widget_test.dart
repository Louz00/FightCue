import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:fightcue_mobile/src/app.dart';

void main() {
  testWidgets('FightCue app renders the redesigned home shell', (tester) async {
    SharedPreferences.setMockInitialValues({});
    await tester.pumpWidget(const FightCueApp());
    await tester.pumpAndSettle();

    expect(find.text('Upcoming fights'), findsOneWidget);
    expect(find.text('Home'), findsOneWidget);
    expect(find.text('Following'), findsWidgets);
  });
}
