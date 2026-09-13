import 'package:chronowarp/data/marathon_catalog.dart';
import 'package:chronowarp/data/universe_configs.dart';
import 'package:chronowarp/models/marathon.dart';
import 'package:chronowarp/models/watch_stats.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final release = universeMarathon(wizardingWorldConfig, ViewingOrder.release);
  final chrono = universeMarathon(
    wizardingWorldConfig,
    ViewingOrder.chronological,
  );
  test('existing completion appears and unwatching removes it', () {
    final entry = release.entries.first;
    var stats = WatchStats.calculate(
      [release],
      {
        release.id: RunProgress({
          entry.id: {entry.mediaId},
        }),
      },
    );
    expect(stats.movies, 1);
    expect(stats.episodes, 0);
    stats = WatchStats.calculate([release], {release.id: RunProgress()});
    expect(stats.movies, 0);
  });
  test('same film across orders counts once and games are excluded', () {
    final entry = release.entries.first;
    final other = chrono.entries.firstWhere((e) => e.mediaId == entry.mediaId);
    final game = chrono.entries.first;
    final stats = WatchStats.calculate(
      [release, chrono],
      {
        release.id: RunProgress({
          entry.id: {entry.mediaId},
        }),
        chrono.id: RunProgress({
          other.id: {other.mediaId},
          game.id: {game.mediaId},
        }),
      },
    );
    expect(stats.movies, 1);
  });
  test('partial seasons and custom selections count unique valid episodes', () {
    final media = CatalogMedia(
      id: 'show',
      universeId: 'private',
      kind: MediaKind.season,
      title: 'Show',
      episodes: const [
        EpisodeRecord(id: 'ep1', number: 1),
        EpisodeRecord(id: 'ep2', number: 2),
        EpisodeRecord(id: 'ep3', number: 3),
      ],
    );
    final definition = MarathonDefinition(
      id: 'custom',
      title: 'Custom',
      order: ViewingOrder.custom,
      entries: [
        MarathonEntry(
          id: 'first',
          mediaId: media.id,
          episodeIds: ['ep1', 'ep2'],
        ),
        MarathonEntry(id: 'repeat', mediaId: media.id),
      ],
      media: {media.id: media},
    );
    final stats = WatchStats.calculate(
      [definition],
      {
        definition.id: RunProgress({
          'first': {'ep1', 'ep3'},
          'repeat': {'ep1', 'ep2', 'stale'},
        }),
      },
    );
    expect(stats.movies, 0);
    expect(stats.episodes, 2);
  });
  test('removed entries and unknown runs do not inflate totals', () {
    final stats = WatchStats.calculate(
      [release],
      {
        release.id: RunProgress({
          'removed': {'old-film'},
        }),
        'deleted-list': RunProgress({
          'old': {'old-film'},
        }),
      },
    );
    expect(stats.movies, 0);
    expect(stats.episodes, 0);
  });
}
