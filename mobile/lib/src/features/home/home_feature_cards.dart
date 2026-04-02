part of 'home_screen.dart';

class _QuietAdFoundationSlot extends StatelessWidget {
  const _QuietAdFoundationSlot({
    required this.strings,
    required this.adsEnabled,
  });

  final AppStrings strings;
  final bool adsEnabled;

  @override
  Widget build(BuildContext context) {
    return FightCueAdSlot(
      strings: strings,
      adsEnabled: adsEnabled,
    );
  }
}
