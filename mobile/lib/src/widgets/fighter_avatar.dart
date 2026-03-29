import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../core/theme/app_theme.dart';

class FighterAvatar extends StatelessWidget {
  const FighterAvatar({
    super.key,
    required this.name,
    this.size = 56,
  });

  final String name;
  final double size;

  @override
  Widget build(BuildContext context) {
    final palette = _paletteForName(name);
    final initials = _initialsForName(name);

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [palette.top, palette.bottom],
        ),
        boxShadow: AppShadows.card,
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Positioned.fill(
            child: CustomPaint(
              painter: _AvatarPainter(
                skinTone: palette.skin,
                hairTone: palette.hair,
                accent: palette.accent,
              ),
            ),
          ),
          Positioned(
            bottom: size * 0.08,
            child: Container(
              padding: EdgeInsets.symmetric(
                horizontal: size * 0.12,
                vertical: size * 0.04,
              ),
              decoration: BoxDecoration(
                color: const Color(0xCC101010),
                borderRadius: BorderRadius.circular(999),
              ),
              child: Text(
                initials,
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
                  fontSize: size * 0.17,
                  letterSpacing: 0.3,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _AvatarPainter extends CustomPainter {
  const _AvatarPainter({
    required this.skinTone,
    required this.hairTone,
    required this.accent,
  });

  final Color skinTone;
  final Color hairTone;
  final Color accent;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final headRadius = size.width * 0.2;
    final shoulderRect = Rect.fromCenter(
      center: Offset(center.dx, size.height * 0.76),
      width: size.width * 0.72,
      height: size.height * 0.34,
    );

    final shoulderPaint = Paint()..color = const Color(0xE6FFFFFF);
    canvas.drawOval(shoulderRect, shoulderPaint);

    final headPaint = Paint()..color = skinTone;
    canvas.drawCircle(Offset(center.dx, size.height * 0.40), headRadius, headPaint);

    final hairPath = Path()
      ..moveTo(size.width * 0.28, size.height * 0.39)
      ..quadraticBezierTo(
        size.width * 0.50,
        size.height * 0.16,
        size.width * 0.72,
        size.height * 0.39,
      )
      ..quadraticBezierTo(
        size.width * 0.50,
        size.height * 0.26,
        size.width * 0.28,
        size.height * 0.39,
      )
      ..close();
    canvas.drawPath(hairPath, Paint()..color = hairTone);

    final accentPaint = Paint()
      ..color = accent
      ..strokeWidth = math.max(2, size.width * 0.035)
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(
      Offset(size.width * 0.22, size.height * 0.22),
      Offset(size.width * 0.72, size.height * 0.60),
      accentPaint,
    );
  }

  @override
  bool shouldRepaint(covariant _AvatarPainter oldDelegate) {
    return oldDelegate.skinTone != skinTone ||
        oldDelegate.hairTone != hairTone ||
        oldDelegate.accent != accent;
  }
}

class _AvatarPalette {
  const _AvatarPalette({
    required this.top,
    required this.bottom,
    required this.skin,
    required this.hair,
    required this.accent,
  });

  final Color top;
  final Color bottom;
  final Color skin;
  final Color hair;
  final Color accent;
}

_AvatarPalette _paletteForName(String name) {
  const palettes = [
    _AvatarPalette(
      top: Color(0xFFF1D7D0),
      bottom: Color(0xFFD30F2F),
      skin: Color(0xFFF4C7A8),
      hair: Color(0xFF2A1B17),
      accent: Color(0xFFFFFFFF),
    ),
    _AvatarPalette(
      top: Color(0xFFE7E2DA),
      bottom: Color(0xFF97001C),
      skin: Color(0xFFD8A580),
      hair: Color(0xFF101010),
      accent: Color(0xFFF7C8CF),
    ),
    _AvatarPalette(
      top: Color(0xFFDCE6EC),
      bottom: Color(0xFFD30F2F),
      skin: Color(0xFFE5BB93),
      hair: Color(0xFF362A24),
      accent: Color(0xFFFFFFFF),
    ),
    _AvatarPalette(
      top: Color(0xFFEDE1C8),
      bottom: Color(0xFFB20C27),
      skin: Color(0xFFC98C69),
      hair: Color(0xFF1A1A1A),
      accent: Color(0xFFFBE4E8),
    ),
  ];

  final hash = name.runes.fold<int>(0, (value, rune) => value + rune);
  return palettes[hash % palettes.length];
}

String _initialsForName(String name) {
  final parts = name.split(' ').where((part) => part.isNotEmpty).toList();
  if (parts.isEmpty) {
    return 'FC';
  }

  if (parts.length == 1) {
    return parts.first.substring(0, math.min(2, parts.first.length)).toUpperCase();
  }

  return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
}
