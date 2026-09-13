import 'package:chronowarp/data/marathon_catalog.dart';
import 'package:chronowarp/data/universe_configs.dart';
import 'package:chronowarp/models/marathon.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test(
    'Hunger Games orders share six films with stable tracking identities',
    () {
      final release = universeMarathon(hungerGamesConfig, ViewingOrder.release);
      final chrono = universeMarathon(
        hungerGamesConfig,
        ViewingOrder.chronological,
      );
      expect(release.entries.length, 6);
      expect(chrono.entries.length, 6);
      expect(
        release.entries.map((e) => e.mediaId).toSet(),
        chrono.entries.map((e) => e.mediaId).toSet(),
      );
      expect(hungerGamesConfig.releaseItems.map((m) => m.year), [
        2012,
        2013,
        2014,
        2015,
        2023,
        2026,
      ]);
      expect(hungerGamesConfig.chronologicalItems.map((m) => m.year), [
        2023,
        2026,
        2012,
        2013,
        2014,
        2015,
      ]);
      expect(
        release.media[release.entries.last.mediaId]!.runtimeMinutes,
        isNull,
      );
      expect(availableUniverses, contains(hungerGamesConfig));
      expect(universeConfigFor('The Hunger Games'), hungerGamesConfig);
      expect(
        release.media.values.every((m) => m.kind == MediaKind.movie),
        isTrue,
      );
    },
  );
}
