import 'package:chronowarp/data/marathon_catalog.dart';
import 'package:chronowarp/data/universe_configs.dart';
import 'package:chronowarp/models/marathon.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test(
    'Wizarding World orders share all 12 titles and preserve game metadata',
    () {
      final release = universeMarathon(
        wizardingWorldConfig,
        ViewingOrder.release,
      );
      final chrono = universeMarathon(
        wizardingWorldConfig,
        ViewingOrder.chronological,
      );
      expect(release.entries.length, 12);
      expect(chrono.entries.length, 12);
      expect(
        release.entries.map((e) => e.mediaId).toSet(),
        chrono.entries.map((e) => e.mediaId).toSet(),
      );
      expect(
        release.media.values.where((m) => m.kind == MediaKind.movie).length,
        11,
      );
      expect(
        release.media[release.entries.first.mediaId]!.title,
        "Harry Potter and the Philosopher's Stone",
      );
      final game = chrono.media[chrono.entries.first.mediaId]!;
      expect(game.title, 'Hogwarts Legacy');
      expect(game.kind, MediaKind.game);
      expect(game.runtimeMinutes, isNull);
      expect(game.durationLabel, '25-80h play time');
      final restored = CatalogMedia.fromJson(game.toJson());
      expect(restored.developer, 'Avalanche Software');
      expect(restored.playtime, game.playtime);
      expect(release.entries.last.mediaId, game.id);
      expect(availableUniverses, contains(wizardingWorldConfig));
      expect(universeConfigFor('Wizarding World'), wizardingWorldConfig);
      expect(release.media.values.every((m) => m.poster == ''), isTrue);
      final progress = RunProgress.fromJson({});
      expect(progress.isComplete(chrono.entries.first, game), isFalse);
    },
  );
}
