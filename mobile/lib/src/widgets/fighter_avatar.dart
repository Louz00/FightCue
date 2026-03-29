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
    final profile = _profileForName(name);
    final initials = _initialsForName(name);

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        boxShadow: AppShadows.card,
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Positioned.fill(
            child: CustomPaint(
              painter: _AvatarPainter(profile: profile),
            ),
          ),
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

class _AvatarPainter extends CustomPainter {
  const _AvatarPainter({required this.profile});

  final _AvatarProfile profile;

  @override
  void paint(Canvas canvas, Size size) {
    final outerRect = Offset.zero & size;
    final clipPath = Path()..addOval(outerRect);

    canvas.save();
    canvas.clipPath(clipPath);

    _paintBackground(canvas, size);
    _paintAccentPattern(canvas, size);
    _paintTorso(canvas, size);
    _paintHead(canvas, size);
    _paintHair(canvas, size);
    _paintFacialHair(canvas, size);
    _paintFaceDetails(canvas, size);

    canvas.restore();

    canvas.drawOval(
      outerRect.deflate(size.width * 0.015),
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = math.max(2, size.width * 0.03)
        ..color = const Color(0x22FFFFFF),
    );
  }

  void _paintBackground(Canvas canvas, Size size) {
    final backgroundPaint = Paint()
      ..shader = RadialGradient(
        center: const Alignment(-0.35, -0.42),
        radius: 1.0,
        colors: [profile.palette.top, profile.palette.bottom],
      ).createShader(Offset.zero & size);
    canvas.drawRect(Offset.zero & size, backgroundPaint);

    final lightSweep = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: const [
          Color(0x22FFFFFF),
          Color(0x00FFFFFF),
          Color(0x14FFFFFF),
        ],
        stops: const [0.0, 0.45, 1.0],
      ).createShader(Offset.zero & size);
    canvas.drawRect(Offset.zero & size, lightSweep);
  }

  void _paintAccentPattern(Canvas canvas, Size size) {
    final accentFill = Paint()
      ..color = profile.palette.accent.withValues(alpha: 0.18);
    final accentStroke = Paint()
      ..color = profile.palette.accent.withValues(alpha: 0.28)
      ..style = PaintingStyle.stroke
      ..strokeWidth = math.max(2, size.width * 0.03);

    switch (profile.backgroundPattern) {
      case _AvatarBackgroundPattern.rays:
        final rayPath = Path()
          ..moveTo(size.width * 0.76, -size.height * 0.02)
          ..lineTo(size.width * 1.05, size.height * 0.22)
          ..lineTo(size.width * 0.74, size.height * 0.54)
          ..close();
        canvas.drawPath(rayPath, accentFill);
        canvas.drawLine(
          Offset(size.width * 0.7, size.height * 0.05),
          Offset(size.width * 0.96, size.height * 0.36),
          accentStroke,
        );
      case _AvatarBackgroundPattern.arcs:
        final arcRect = Rect.fromCircle(
          center: Offset(size.width * 0.24, size.height * 0.24),
          radius: size.width * 0.42,
        );
        canvas.drawArc(arcRect, 0.3, 1.6, false, accentStroke);
        canvas.drawArc(arcRect.inflate(size.width * 0.08), 0.5, 1.2, false, accentStroke);
      case _AvatarBackgroundPattern.bars:
        final barWidth = size.width * 0.12;
        for (var index = 0; index < 3; index++) {
          final left = size.width * (0.12 + (index * 0.15));
          canvas.drawRRect(
            RRect.fromRectAndRadius(
              Rect.fromLTWH(left, size.height * 0.1, barWidth, size.height * 0.5),
              Radius.circular(size.width * 0.06),
            ),
            accentFill,
          );
        }
      case _AvatarBackgroundPattern.halo:
        canvas.drawCircle(
          Offset(size.width * 0.5, size.height * 0.24),
          size.width * 0.26,
          Paint()
            ..color = profile.palette.accent.withValues(alpha: 0.18)
            ..style = PaintingStyle.stroke
            ..strokeWidth = size.width * 0.1,
        );
        canvas.drawCircle(
          Offset(size.width * 0.5, size.height * 0.24),
          size.width * 0.19,
          Paint()
            ..color = profile.palette.accent.withValues(alpha: 0.12),
        );
    }
  }

  void _paintTorso(Canvas canvas, Size size) {
    final bodyPaint = Paint()..color = profile.palette.outfit;
    final shadowPaint = Paint()..color = profile.palette.outfitShadow;

    final torsoRect = Rect.fromCenter(
      center: Offset(size.width * 0.5, size.height * 0.83),
      width: size.width * profile.torsoWidth,
      height: size.height * 0.36,
    );
    canvas.drawOval(torsoRect, bodyPaint);

    final neckRect = RRect.fromRectAndRadius(
      Rect.fromCenter(
        center: Offset(size.width * 0.5, size.height * 0.62),
        width: size.width * 0.16,
        height: size.height * 0.14,
      ),
      Radius.circular(size.width * 0.06),
    );
    canvas.drawRRect(neckRect, Paint()..color = profile.palette.skin);

    switch (profile.outfitStyle) {
      case _AvatarOutfitStyle.jacket:
        final jacketPath = Path()
          ..moveTo(size.width * 0.24, size.height * 0.74)
          ..quadraticBezierTo(
            size.width * 0.50,
            size.height * 0.60,
            size.width * 0.76,
            size.height * 0.74,
          )
          ..lineTo(size.width * 0.70, size.height * 1.02)
          ..lineTo(size.width * 0.30, size.height * 1.02)
          ..close();
        canvas.drawPath(jacketPath, bodyPaint);
        canvas.drawLine(
          Offset(size.width * 0.50, size.height * 0.72),
          Offset(size.width * 0.50, size.height * 1.0),
          Paint()
            ..color = Colors.white.withValues(alpha: 0.28)
            ..strokeWidth = size.width * 0.04,
        );
      case _AvatarOutfitStyle.hoodie:
        final hoodPath = Path()
          ..moveTo(size.width * 0.30, size.height * 0.70)
          ..quadraticBezierTo(
            size.width * 0.50,
            size.height * 0.50,
            size.width * 0.70,
            size.height * 0.70,
          )
          ..quadraticBezierTo(
            size.width * 0.50,
            size.height * 0.86,
            size.width * 0.30,
            size.height * 0.70,
          )
          ..close();
        canvas.drawPath(hoodPath, shadowPaint);
      case _AvatarOutfitStyle.singlet:
        canvas.drawLine(
          Offset(size.width * 0.36, size.height * 0.66),
          Offset(size.width * 0.28, size.height * 0.95),
          Paint()
            ..color = Colors.white.withValues(alpha: 0.35)
            ..strokeWidth = size.width * 0.08
            ..strokeCap = StrokeCap.round,
        );
        canvas.drawLine(
          Offset(size.width * 0.64, size.height * 0.66),
          Offset(size.width * 0.72, size.height * 0.95),
          Paint()
            ..color = Colors.white.withValues(alpha: 0.35)
            ..strokeWidth = size.width * 0.08
            ..strokeCap = StrokeCap.round,
        );
      case _AvatarOutfitStyle.collar:
        final collarPath = Path()
          ..moveTo(size.width * 0.42, size.height * 0.67)
          ..lineTo(size.width * 0.50, size.height * 0.79)
          ..lineTo(size.width * 0.58, size.height * 0.67);
        canvas.drawPath(
          collarPath,
          Paint()
            ..color = Colors.white.withValues(alpha: 0.36)
            ..style = PaintingStyle.stroke
            ..strokeWidth = size.width * 0.05,
        );
    }
  }

  void _paintHead(Canvas canvas, Size size) {
    final headPath = _headPath(size, profile.headShape);
    canvas.drawPath(headPath, Paint()..color = profile.palette.skin);
    canvas.drawPath(
      headPath,
      Paint()
        ..color = Colors.black.withValues(alpha: 0.08)
        ..style = PaintingStyle.stroke
        ..strokeWidth = size.width * 0.015,
    );

    final earPaint = Paint()..color = profile.palette.skin;
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(size.width * 0.32, size.height * 0.41),
        width: size.width * 0.06,
        height: size.height * 0.12,
      ),
      earPaint,
    );
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(size.width * 0.68, size.height * 0.41),
        width: size.width * 0.06,
        height: size.height * 0.12,
      ),
      earPaint,
    );
  }

  void _paintHair(Canvas canvas, Size size) {
    final paint = Paint()..color = profile.palette.hair;
    late final Path path;

    switch (profile.hairStyle) {
      case _AvatarHairStyle.buzz:
        path = Path()
          ..addOval(
            Rect.fromCenter(
              center: Offset(size.width * 0.5, size.height * 0.30),
              width: size.width * 0.42,
              height: size.height * 0.18,
            ),
          );
      case _AvatarHairStyle.crop:
        path = Path()
          ..moveTo(size.width * 0.29, size.height * 0.38)
          ..quadraticBezierTo(
            size.width * 0.50,
            size.height * 0.16,
            size.width * 0.71,
            size.height * 0.38,
          )
          ..quadraticBezierTo(
            size.width * 0.49,
            size.height * 0.28,
            size.width * 0.29,
            size.height * 0.38,
          )
          ..close();
      case _AvatarHairStyle.swept:
        path = Path()
          ..moveTo(size.width * 0.24, size.height * 0.39)
          ..quadraticBezierTo(
            size.width * 0.38,
            size.height * 0.08,
            size.width * 0.77,
            size.height * 0.31,
          )
          ..quadraticBezierTo(
            size.width * 0.64,
            size.height * 0.40,
            size.width * 0.27,
            size.height * 0.43,
          )
          ..close();
      case _AvatarHairStyle.crest:
        path = Path()
          ..moveTo(size.width * 0.38, size.height * 0.40)
          ..lineTo(size.width * 0.45, size.height * 0.10)
          ..lineTo(size.width * 0.55, size.height * 0.10)
          ..lineTo(size.width * 0.62, size.height * 0.40)
          ..close();
    }

    canvas.drawPath(path, paint);
  }

  void _paintFacialHair(Canvas canvas, Size size) {
    final beardPaint = Paint()..color = profile.palette.hair.withValues(alpha: 0.94);

    switch (profile.facialHairStyle) {
      case _AvatarFacialHairStyle.none:
        return;
      case _AvatarFacialHairStyle.stubble:
        canvas.drawArc(
          Rect.fromCenter(
            center: Offset(size.width * 0.5, size.height * 0.50),
            width: size.width * 0.28,
            height: size.height * 0.16,
          ),
          0.25,
          math.pi - 0.5,
          false,
          Paint()
            ..color = profile.palette.hair.withValues(alpha: 0.45)
            ..style = PaintingStyle.stroke
            ..strokeWidth = size.width * 0.03,
        );
      case _AvatarFacialHairStyle.mustache:
        final mustachePath = Path()
          ..moveTo(size.width * 0.42, size.height * 0.47)
          ..quadraticBezierTo(
            size.width * 0.47,
            size.height * 0.49,
            size.width * 0.50,
            size.height * 0.47,
          )
          ..quadraticBezierTo(
            size.width * 0.53,
            size.height * 0.49,
            size.width * 0.58,
            size.height * 0.47,
          );
        canvas.drawPath(
          mustachePath,
          beardPaint
            ..style = PaintingStyle.stroke
            ..strokeWidth = size.width * 0.035
            ..strokeCap = StrokeCap.round,
        );
      case _AvatarFacialHairStyle.full:
        final beardPath = Path()
          ..moveTo(size.width * 0.36, size.height * 0.46)
          ..quadraticBezierTo(
            size.width * 0.50,
            size.height * 0.64,
            size.width * 0.64,
            size.height * 0.46,
          )
          ..quadraticBezierTo(
            size.width * 0.50,
            size.height * 0.58,
            size.width * 0.36,
            size.height * 0.46,
          )
          ..close();
        canvas.drawPath(beardPath, beardPaint);
    }
  }

  void _paintFaceDetails(Canvas canvas, Size size) {
    final featurePaint = Paint()
      ..color = const Color(0xD9101010)
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;
    final eyeY = size.height * 0.41;
    final eyeSpread = size.width * profile.eyeSpread;
    final browTilt = size.height * profile.browTilt;

    featurePaint.strokeWidth = size.width * 0.028;
    canvas.drawLine(
      Offset(size.width * (0.5 - eyeSpread) - size.width * 0.045, eyeY - browTilt),
      Offset(size.width * (0.5 - eyeSpread) + size.width * 0.035, eyeY - browTilt * 1.7),
      featurePaint,
    );
    canvas.drawLine(
      Offset(size.width * (0.5 + eyeSpread) - size.width * 0.035, eyeY - browTilt * 1.7),
      Offset(size.width * (0.5 + eyeSpread) + size.width * 0.045, eyeY - browTilt),
      featurePaint,
    );

    featurePaint.strokeWidth = size.width * 0.02;
    canvas.drawLine(
      Offset(size.width * (0.5 - eyeSpread) - size.width * 0.04, eyeY),
      Offset(size.width * (0.5 - eyeSpread) + size.width * 0.03, eyeY),
      featurePaint,
    );
    canvas.drawLine(
      Offset(size.width * (0.5 + eyeSpread) - size.width * 0.03, eyeY),
      Offset(size.width * (0.5 + eyeSpread) + size.width * 0.04, eyeY),
      featurePaint,
    );

    featurePaint.strokeWidth = size.width * 0.018;
    final nosePath = Path()
      ..moveTo(size.width * 0.5, size.height * 0.43)
      ..quadraticBezierTo(
        size.width * 0.48,
        size.height * 0.47,
        size.width * 0.50,
        size.height * 0.51,
      )
      ..quadraticBezierTo(
        size.width * 0.52,
        size.height * 0.50,
        size.width * 0.49,
        size.height * 0.52,
      );
    canvas.drawPath(nosePath, featurePaint);

    canvas.drawArc(
      Rect.fromCenter(
        center: Offset(size.width * 0.5, size.height * 0.56),
        width: size.width * 0.16,
        height: size.height * 0.09,
      ),
      0.2,
      math.pi - 0.4,
      false,
      featurePaint
        ..color = const Color(0xC6141414)
        ..strokeWidth = size.width * 0.018,
    );
  }

  Path _headPath(Size size, _AvatarHeadShape shape) {
    switch (shape) {
      case _AvatarHeadShape.round:
        return Path()
          ..addOval(
            Rect.fromCenter(
              center: Offset(size.width * 0.5, size.height * 0.40),
              width: size.width * 0.40,
              height: size.height * 0.44,
            ),
          );
      case _AvatarHeadShape.oval:
        return Path()
          ..addOval(
            Rect.fromCenter(
              center: Offset(size.width * 0.5, size.height * 0.41),
              width: size.width * 0.38,
              height: size.height * 0.48,
            ),
          );
      case _AvatarHeadShape.square:
        return Path()
          ..addRRect(
            RRect.fromRectAndRadius(
              Rect.fromCenter(
                center: Offset(size.width * 0.5, size.height * 0.41),
                width: size.width * 0.38,
                height: size.height * 0.46,
              ),
              Radius.circular(size.width * 0.09),
            ),
          );
      case _AvatarHeadShape.tapered:
        return Path()
          ..moveTo(size.width * 0.34, size.height * 0.26)
          ..quadraticBezierTo(
            size.width * 0.50,
            size.height * 0.18,
            size.width * 0.66,
            size.height * 0.26,
          )
          ..quadraticBezierTo(
            size.width * 0.74,
            size.height * 0.40,
            size.width * 0.60,
            size.height * 0.58,
          )
          ..quadraticBezierTo(
            size.width * 0.50,
            size.height * 0.66,
            size.width * 0.40,
            size.height * 0.58,
          )
          ..quadraticBezierTo(
            size.width * 0.26,
            size.height * 0.40,
            size.width * 0.34,
            size.height * 0.26,
          )
          ..close();
    }
  }

  @override
  bool shouldRepaint(covariant _AvatarPainter oldDelegate) {
    return oldDelegate.profile != profile;
  }
}

enum _AvatarHeadShape { round, oval, square, tapered }

enum _AvatarHairStyle { buzz, crop, swept, crest }

enum _AvatarFacialHairStyle { none, stubble, mustache, full }

enum _AvatarBackgroundPattern { rays, arcs, bars, halo }

enum _AvatarOutfitStyle { jacket, hoodie, singlet, collar }

class _AvatarPalette {
  const _AvatarPalette({
    required this.top,
    required this.bottom,
    required this.skin,
    required this.hair,
    required this.accent,
    required this.outfit,
    required this.outfitShadow,
  });

  final Color top;
  final Color bottom;
  final Color skin;
  final Color hair;
  final Color accent;
  final Color outfit;
  final Color outfitShadow;
}

class _AvatarProfile {
  const _AvatarProfile({
    required this.palette,
    required this.headShape,
    required this.hairStyle,
    required this.facialHairStyle,
    required this.backgroundPattern,
    required this.outfitStyle,
    required this.eyeSpread,
    required this.browTilt,
    required this.torsoWidth,
  });

  final _AvatarPalette palette;
  final _AvatarHeadShape headShape;
  final _AvatarHairStyle hairStyle;
  final _AvatarFacialHairStyle facialHairStyle;
  final _AvatarBackgroundPattern backgroundPattern;
  final _AvatarOutfitStyle outfitStyle;
  final double eyeSpread;
  final double browTilt;
  final double torsoWidth;

  @override
  bool operator ==(Object other) {
    return other is _AvatarProfile &&
        other.palette == palette &&
        other.headShape == headShape &&
        other.hairStyle == hairStyle &&
        other.facialHairStyle == facialHairStyle &&
        other.backgroundPattern == backgroundPattern &&
        other.outfitStyle == outfitStyle &&
        other.eyeSpread == eyeSpread &&
        other.browTilt == browTilt &&
        other.torsoWidth == torsoWidth;
  }

  @override
  int get hashCode => Object.hash(
        palette,
        headShape,
        hairStyle,
        facialHairStyle,
        backgroundPattern,
        outfitStyle,
        eyeSpread,
        browTilt,
        torsoWidth,
      );
}

_AvatarProfile _profileForName(String name) {
  const palettes = [
    _AvatarPalette(
      top: Color(0xFFF0D7CF),
      bottom: Color(0xFFD30F2F),
      skin: Color(0xFFF3C3A1),
      hair: Color(0xFF291C17),
      accent: Color(0xFFFFFFFF),
      outfit: Color(0xFF8F031B),
      outfitShadow: Color(0xFF630011),
    ),
    _AvatarPalette(
      top: Color(0xFFE9E1D5),
      bottom: Color(0xFF97001C),
      skin: Color(0xFFD79F79),
      hair: Color(0xFF181818),
      accent: Color(0xFFFBE6EA),
      outfit: Color(0xFF2C2C2C),
      outfitShadow: Color(0xFF111111),
    ),
    _AvatarPalette(
      top: Color(0xFFD7E6ED),
      bottom: Color(0xFFD30F2F),
      skin: Color(0xFFE0B48D),
      hair: Color(0xFF352923),
      accent: Color(0xFFFFFFFF),
      outfit: Color(0xFF1D2C35),
      outfitShadow: Color(0xFF0E171B),
    ),
    _AvatarPalette(
      top: Color(0xFFEFE2C5),
      bottom: Color(0xFFB20C27),
      skin: Color(0xFFC88964),
      hair: Color(0xFF181312),
      accent: Color(0xFFFCE5E9),
      outfit: Color(0xFF5A0A18),
      outfitShadow: Color(0xFF34060E),
    ),
  ];

  final hash = name.runes.fold<int>(0, (value, rune) => value * 31 + rune);
  final normalized = hash.abs();

  return _AvatarProfile(
    palette: palettes[normalized % palettes.length],
    headShape: _AvatarHeadShape.values[normalized % _AvatarHeadShape.values.length],
    hairStyle: _AvatarHairStyle.values[(normalized ~/ 7) % _AvatarHairStyle.values.length],
    facialHairStyle: _AvatarFacialHairStyle
        .values[(normalized ~/ 11) % _AvatarFacialHairStyle.values.length],
    backgroundPattern: _AvatarBackgroundPattern
        .values[(normalized ~/ 13) % _AvatarBackgroundPattern.values.length],
    outfitStyle:
        _AvatarOutfitStyle.values[(normalized ~/ 17) % _AvatarOutfitStyle.values.length],
    eyeSpread: 0.13 + ((normalized % 7) * 0.005),
    browTilt: 0.004 + ((normalized % 5) * 0.003),
    torsoWidth: 0.70 + ((normalized % 4) * 0.04),
  );
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
