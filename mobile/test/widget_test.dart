import 'package:flutter_test/flutter_test.dart';

import 'package:fightcue_mobile/src/app.dart';

void main() {
  testWidgets('FightCue app renders shell labels', (tester) async {
    await tester.pumpWidget(const FightCueApp());
    await tester.pumpAndSettle();

    expect(find.text('FightCue'), findsWidgets);
  });
}
