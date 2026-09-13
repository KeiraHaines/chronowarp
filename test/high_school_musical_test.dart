import 'package:chronowarp/data/marathon_catalog.dart';
import 'package:chronowarp/data/universe_configs.dart';
import 'package:chronowarp/models/marathon.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test(
    'HSM includes films, specials and all individually tracked episodes',
    () {
      final list = universeMarathon(
        highSchoolMusicalConfig,
        ViewingOrder.release,
      );
      expect(list.entries.length, 9);
      expect(highSchoolMusicalConfig.hasMultipleOrders, isFalse);
      final seasons = list.media.values.where(
        (m) => m.kind == MediaKind.season,
      );
      expect(seasons.map((m) => m.episodes.length), [10, 12, 8, 8]);
      final episodes = seasons.expand((m) => m.episodes);
      expect(episodes.map((e) => e.id).toSet().length, 38);
      expect(
        episodes.every((e) => e.title != null && e.title!.isNotEmpty),
        isTrue,
      );
      expect(
        list.media.values.where((m) => m.kind == MediaKind.movie).length,
        5,
      );
      expect(universeConfigFor('High School Musical'), highSchoolMusicalConfig);
      expect(availableUniverses, contains(highSchoolMusicalConfig));
      expect(
        universeMarathon(
          highSchoolMusicalConfig,
          ViewingOrder.chronological,
        ).id,
        list.id,
      );
    },
  );
}
