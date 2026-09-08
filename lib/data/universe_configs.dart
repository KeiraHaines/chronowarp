import 'package:flutter/material.dart';
import '../widgets/universe_watch_page.dart';
import 'lionking_data.dart';
import 'marvel_data.dart';
import 'pixar_data.dart';

final lionKingConfig = UniverseConfig(
  title: 'The Lion King',
  releaseItems: lionKingReleaseOrder,
  chronologicalItems: lionKingChronologicalOrder,
  bgPage: const Color(0XFF1F3A2E),
  bgCard: const Color(0XFFFFF3CF),
  bgChip: const Color(0XFF6FA66A),
  accentPrimary: const Color(0XFFE6A23C),
  accentSecondary: const Color(0XFFD94F30),
  textPrimary: const Color(0XFFF6EAD1),
  textMuted: const Color.fromARGB(255, 255, 255, 255),
  textCard: const Color(0XFF3A2415),
  textCardMuted: const Color(0XFF8A6A45),
);

final marvelConfig = UniverseConfig(
  title: 'Marvel Cinematic Universe',
  releaseItems: mcuReleaseOrder,
  chronologicalItems: mcuChronologicalOrder,
  bgPage: const Color(0XFFF7FAFC),
  bgCard: const Color(0XFFFFFFFF),
  bgChip: const Color(0XFFD9ECF7),
  accentPrimary: const Color(0XFFF0141A),
  accentSecondary: const Color(0XFF0499D7),
  textPrimary: const Color(0XFF052451),
  textMuted: const Color(0XFF6E7F93),
  textCard: const Color(0XFF102A43),
  textCardMuted: const Color(0XFF8FA8B8),
);

final pixarConfig = UniverseConfig(
  title: 'Pixar',
  releaseItems: pixarOrder,
  chronologicalItems: const [],
  bgPage: const Color(0XFFA9463D),
  bgCard: const Color(0XFFFFF6E2),
  bgChip: const Color(0XFF557A9D),
  accentPrimary: const Color(0XFFD9A23A),
  accentSecondary: const Color(0XFFB93630),
  textPrimary: const Color(0XFFFFF7EA),
  textMuted: const Color(0XFFD9C6B8),
  textCard: const Color(0XFF24313C),
  textCardMuted: const Color(0XFF8B7352),
);

final starWarsConfig = UniverseConfig(
  title: 'Star Wars',
  releaseItems: const [],
  chronologicalItems: const [],
  bgPage: const Color(0xFF111D29),
  bgCard: const Color(0xFFF4EEDB),
  bgChip: const Color(0xFF34485B),
  accentPrimary: const Color(0xFFE8B955),
  accentSecondary: const Color(0xFFE8B955),
  textPrimary: const Color(0xFFF4EEDB),
  textMuted: const Color(0xFFF4EEDB),
  textCard: const Color(0xFF202F3A),
  textCardMuted: const Color(0xFF786C50),
);

UniverseConfig? universeConfigFor(String key) => switch (key) {
  'Lion King' || 'The Lion King' => lionKingConfig,
  'Marvel Cinematic Universe' => marvelConfig,
  'Pixar' => pixarConfig,
  'Star Wars' || 'Star Wars Universe' => starWarsConfig,
  _ => null,
};
