part of 'fighter_avatar.dart';

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
    hairStyle:
        _AvatarHairStyle.values[(normalized ~/ 7) % _AvatarHairStyle.values.length],
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
