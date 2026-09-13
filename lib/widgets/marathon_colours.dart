import 'package:flutter/material.dart';

class MarathonColours {
  final String id, label;
  final Color background, card, accent, secondary;
  MarathonColours(
    this.id,
    this.label,
    int bg,
    int surface,
    int primary,
    int highlight,
  ) : background = Color(bg),
      card = Color(surface),
      accent = Color(primary),
      secondary = Color(highlight);
  static final options = [
    MarathonColours(
      'classic',
      'Orange & gold',
      0xFF1A2931,
      0xFF283A44,
      0xFFE86D1F,
      0xFFFFB703,
    ),
    MarathonColours(
      'rose',
      'Pink & gold',
      0xFF38212E,
      0xFF513346,
      0xFFF2A8C5,
      0xFFF0C66C,
    ),
    MarathonColours(
      'ocean',
      'Ocean blue',
      0xFF122839,
      0xFF203E53,
      0xFF70C8F3,
      0xFF8EE3DC,
    ),
    MarathonColours(
      'forest',
      'Forest green',
      0xFF182D25,
      0xFF294337,
      0xFF8AD8A3,
      0xFFE0D28A,
    ),
    MarathonColours(
      'purple',
      'Purple & silver',
      0xFF282039,
      0xFF403252,
      0xFFC9A2F3,
      0xFFDFD9EB,
    ),
    MarathonColours(
      'red',
      'Red & gold',
      0xFF321E23,
      0xFF4D2D34,
      0xFFFF9595,
      0xFFF0C66C,
    ),
  ];
  static MarathonColours forId(String id) =>
      options.firstWhere((p) => p.id == id, orElse: () => options.first);
}
