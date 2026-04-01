import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../core/theme/app_theme.dart';

part 'fighter_avatar_painter.dart';
part 'fighter_avatar_profile.dart';

class FighterAvatar extends StatelessWidget {
  const FighterAvatar({
    super.key,
    required this.name,
    this.size = 56,
    this.showInitialsChip = true,
    this.framed = false,
  });

  final String name;
  final double size;
  final bool showInitialsChip;
  final bool framed;

  @override
  Widget build(BuildContext context) {
    final profile = _profileForName(name);
    final initials = _initialsForName(name);

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        boxShadow: AppShadows.card,
        border: framed
            ? Border.all(
                color: Colors.white,
                width: math.max(2, size * 0.06),
              )
            : null,
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Positioned.fill(
            child: CustomPaint(
              painter: _AvatarPainter(profile: profile),
            ),
          ),
          if (showInitialsChip)
            Positioned(
              bottom: size * 0.07,
              child: Container(
                padding: EdgeInsets.symmetric(
                  horizontal: size * 0.12,
                  vertical: size * 0.035,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xD9101010),
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(color: const Color(0x26FFFFFF)),
                ),
                child: Text(
                  initials,
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w900,
                    fontSize: size * 0.16,
                    letterSpacing: 0.35,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
