import 'lord_of_the_rings_data.dart';
import 'pirates_data.dart';
import 'mission_impossible_data.dart';
import 'jurassic_data.dart';
import 'indiana_jones_data.dart';
import 'dragons_data.dart';
import 'high_school_musical_data.dart';
import 'xmen_data.dart';
import 'james_bond_data.dart';
import 'hunger_games_data.dart';
import 'package:flutter/material.dart';
import '../widgets/universe_watch_page.dart';
import 'lionking_data.dart';
import 'marvel_data.dart';
import 'pixar_data.dart';
import 'wizarding_world_data.dart';
import 'starwars_data.dart';
import 'princess_data.dart';

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
  catalog: marvelCatalog,
  chronologicalEntries: mcuChronologicalEntries,
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
  catalog: starWarsCatalog,
  chronologicalEntries: starWarsChronologicalEntries,
  releaseItems: starWarsReleaseOrder,
  chronologicalItems: starWarsChronologicalOrder,
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
  'Wizarding World' => wizardingWorldConfig,
  'Disney Princess' => princessConfig,
  'James Bond' => jamesBondConfig,
  'X-Men' => xmenConfig,
  'The Lord of the Rings' => lordOfTheRingsConfig,
  'Pirates of the Caribbean' => piratesConfig,
  'Mission: Impossible' => missionImpossibleConfig,
  'Jurassic World' => jurassicConfig,
  'Indiana Jones' => indianaJonesConfig,
  'How to Train Your Dragon' => dragonsConfig,
  'High School Musical' => highSchoolMusicalConfig,
  'The Hunger Games' || 'Hunger Games' => hungerGamesConfig,
  'Star Wars' || 'Star Wars Universe' => starWarsConfig,
  _ => null,
};

final wizardingWorldConfig = UniverseConfig(
  title: 'Wizarding World',
  releaseItems: wizardingWorldReleaseOrder,
  chronologicalItems: wizardingWorldChronologicalOrder,
  bgPage: const Color(0xFF182B32),
  bgCard: const Color(0xFFF5EEDC),
  bgChip: const Color(0xFF34515C),
  accentPrimary: const Color(0xFFD4B46A),
  accentSecondary: const Color(0xFF829EAA),
  textPrimary: const Color(0xFFF5EEDC),
  textMuted: const Color(0xFFCCDBDE),
  textCard: const Color(0xFF182B32),
  textCardMuted: const Color(0xFF59636A),
);

final princessConfig = UniverseConfig(
  title: 'Disney Princess',
  catalog: princessCatalog,
  releaseItems: princessWatchList,
  chronologicalItems: const [],
  bgPage: const Color(0xFF843D59),
  bgCard: const Color(0xFFFFF1F5),
  bgChip: const Color(0xFFF2C9D6),
  accentPrimary: const Color(0xFFF0C66C),
  accentSecondary: const Color(0xFFE8ACBD),
  textPrimary: const Color(0xFFFFF1F5),
  textMuted: const Color(0xFFF5D6DF),
  textCard: const Color(0xFF572A3D),
  textCardMuted: const Color(0xFF815765),
);

final hungerGamesConfig = UniverseConfig(
  title: 'The Hunger Games',
  releaseItems: hungerGamesReleaseOrder,
  chronologicalItems: hungerGamesChronologicalOrder,
  bgPage: const Color(0xFF25241F),
  bgCard: const Color(0xFFFFF0D5),
  bgChip: const Color(0xFF5C4930),
  accentPrimary: const Color(0xFFE6AF47),
  accentSecondary: const Color(0xFFD66B36),
  textPrimary: const Color(0xFFFFF0D5),
  textMuted: const Color(0xFFE0D1B7),
  textCard: const Color(0xFF30261C),
  textCardMuted: const Color(0xFF756249),
);

final jamesBondConfig = UniverseConfig(
  title: 'James Bond',
  releaseItems: jamesBondWatchList,
  chronologicalItems: const [],
  bgPage: const Color(0xFF19232D),
  bgCard: const Color(0xFFF4F0E6),
  bgChip: const Color(0xFF3B4B59),
  accentPrimary: const Color(0xFFD2B574),
  accentSecondary: const Color(0xFF9DAFBD),
  textPrimary: const Color(0xFFF4F0E6),
  textMuted: const Color(0xFFCED6DD),
  textCard: const Color(0xFF19232D),
  textCardMuted: const Color(0xFF626B73),
);

final xmenConfig = UniverseConfig(
  title: 'X-Men',
  releaseItems: xmenReleaseOrder,
  chronologicalItems: xmenChronologicalOrder,
  bgPage: const Color(0xFF152842),
  bgCard: const Color(0xFFF3F1E5),
  bgChip: const Color(0xFF354E6A),
  accentPrimary: const Color(0xFFE8BD44),
  accentSecondary: const Color(0xFF8AB9DD),
  textPrimary: const Color(0xFFF3F1E5),
  textMuted: const Color(0xFFCED9E5),
  textCard: const Color(0xFF152842),
  textCardMuted: const Color(0xFF647180),
);

final highSchoolMusicalConfig = UniverseConfig(
  title: 'High School Musical',
  catalog: highSchoolMusicalCatalog,
  releaseItems: highSchoolMusicalWatchList,
  chronologicalItems: const [],
  bgPage: const Color(0xFF702C36),
  bgCard: const Color(0xFFFFF4E5),
  bgChip: const Color(0xFFA34B51),
  accentPrimary: const Color(0xFFF0C15C),
  accentSecondary: const Color(0xFFFFD7B7),
  textPrimary: const Color(0xFFFFF4E5),
  textMuted: const Color(0xFFF1D1CD),
  textCard: const Color(0xFF49242A),
  textCardMuted: const Color(0xFF815E61),
);

final dragonsConfig = UniverseConfig(
  title: 'How to Train Your Dragon',
  catalog: dragonsCatalog,
  releaseItems: dragonsReleaseOrder,
  chronologicalItems: dragonsChronologicalOrder,
  bgPage: const Color(0xFF183C3C),
  bgCard: const Color(0xFFF3F1E5),
  bgChip: const Color(0xFF354E6A),
  accentPrimary: const Color(0xFFE8BD44),
  accentSecondary: const Color(0xFF8AB9DD),
  textPrimary: const Color(0xFFF3F1E5),
  textMuted: const Color(0xFFCED9E5),
  textCard: const Color(0xFF183C3C),
  textCardMuted: const Color(0xFF647180),
);

final indianaJonesConfig = UniverseConfig(
  title: 'Indiana Jones',
  releaseItems: indianaJonesReleaseOrder,
  chronologicalItems: indianaJonesChronologicalOrder,
  bgPage: const Color(0xFF3C3025),
  bgCard: const Color(0xFFF3F1E5),
  bgChip: const Color(0xFF354E6A),
  accentPrimary: const Color(0xFFE8BD44),
  accentSecondary: const Color(0xFF8AB9DD),
  textPrimary: const Color(0xFFF3F1E5),
  textMuted: const Color(0xFFCED9E5),
  textCard: const Color(0xFF3C3025),
  textCardMuted: const Color(0xFF647180),
);

final jurassicConfig = UniverseConfig(
  title: 'Jurassic World',
  catalog: jurassicCatalog,
  releaseItems: jurassicReleaseOrder,
  chronologicalItems: jurassicChronologicalOrder,
  bgPage: const Color(0xFF183C3C),
  bgCard: const Color(0xFFF3F1E5),
  bgChip: const Color(0xFF354E6A),
  accentPrimary: const Color(0xFFE8BD44),
  accentSecondary: const Color(0xFF8AB9DD),
  textPrimary: const Color(0xFFF3F1E5),
  textMuted: const Color(0xFFCED9E5),
  textCard: const Color(0xFF183C3C),
  textCardMuted: const Color(0xFF647180),
);

final missionImpossibleConfig = UniverseConfig(
  title: 'Mission: Impossible',
  releaseItems: missionImpossibleWatchList,
  chronologicalItems: const [],
  bgPage: const Color(0xFF292C32),
  bgCard: const Color(0xFFF3F1E5),
  bgChip: const Color(0xFF354E6A),
  accentPrimary: const Color(0xFFF19B79),
  accentSecondary: const Color(0xFF8AB9DD),
  textPrimary: const Color(0xFFF3F1E5),
  textMuted: const Color(0xFFCED9E5),
  textCard: const Color(0xFF292C32),
  textCardMuted: const Color(0xFF647180),
);

final piratesConfig = UniverseConfig(
  title: 'Pirates of the Caribbean',
  releaseItems: piratesWatchList,
  chronologicalItems: const [],
  bgPage: const Color(0xFF292C32),
  bgCard: const Color(0xFFF3F1E5),
  bgChip: const Color(0xFF354E6A),
  accentPrimary: const Color(0xFFF19B79),
  accentSecondary: const Color(0xFF8AB9DD),
  textPrimary: const Color(0xFFF3F1E5),
  textMuted: const Color(0xFFCED9E5),
  textCard: const Color(0xFF292C32),
  textCardMuted: const Color(0xFF647180),
);

final lordOfTheRingsConfig = UniverseConfig(
  title: 'The Lord of the Rings',
  releaseItems: lordOfTheRingsReleaseOrder,
  chronologicalItems: lordOfTheRingsChronologicalOrder,
  bgPage: const Color(0xFF3C3025),
  bgCard: const Color(0xFFF3F1E5),
  bgChip: const Color(0xFF354E6A),
  accentPrimary: const Color(0xFFE8BD44),
  accentSecondary: const Color(0xFF8AB9DD),
  textPrimary: const Color(0xFFF3F1E5),
  textMuted: const Color(0xFFCED9E5),
  textCard: const Color(0xFF3C3025),
  textCardMuted: const Color(0xFF647180),
);
