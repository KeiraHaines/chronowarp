import 'package:chronowarp/data/marathon_catalog.dart';
import 'package:chronowarp/data/universe_configs.dart';
import 'package:chronowarp/models/marathon.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final release = universeMarathon(lionKingConfig, ViewingOrder.release);
  final chronology = universeMarathon(
    lionKingConfig,
    ViewingOrder.chronological,
  );
  test('Lion King media identity is independent of list position', () {
    expect(release.entries.first.mediaId, 'lion-king-1994');
    expect(chronology.entries.first.mediaId, 'mufasa-2024');
    expect(chronology.entries[1].mediaId, release.entries.first.mediaId);
    expect(release.id, isNot(chronology.id));
    expect(release.media.length, 13);
    expect(
      chronology.media['lion-king-1994']!.blurb,
      release.media['lion-king-1994']!.blurb,
    );
  });
  test('separate runs do not share completion even for the same film', () {
    final runs = <String, RunProgress>{
      release.id: RunProgress({
        release.entries.first.id: {'lion-king-1994'},
      }),
      chronology.id: RunProgress(),
    };
    expect(
      runs[release.id]!.isComplete(
        release.entries.first,
        release.media['lion-king-1994']!,
      ),
      isTrue,
    );
    expect(
      runs[chronology.id]!.isComplete(
        chronology.entries[1],
        chronology.media['lion-king-1994']!,
      ),
      isFalse,
    );
  });
  final season = CatalogMedia(
    id: 'season-1',
    universeId: 'private',
    kind: MediaKind.season,
    title: 'Example — Season 1',
    episodes: List.generate(
      10,
      (i) => EpisodeRecord(id: 'ep-${i + 1}', number: i + 1),
    ),
  );
  test('episode groups can surround a film and complete independently', () {
    final early = MarathonEntry(
      id: 'early',
      mediaId: season.id,
      episodeIds: ['ep-1', 'ep-2'],
    );
    final late = MarathonEntry(
      id: 'late',
      mediaId: season.id,
      episodeIds: ['ep-8', 'ep-9'],
    );
    final film = CatalogMedia(
      id: 'film',
      universeId: 'private',
      kind: MediaKind.movie,
      title: 'Film',
    );
    final definition = MarathonDefinition(
      id: 'mixed',
      title: 'Mixed order',
      order: ViewingOrder.custom,
      entries: [
        early,
        MarathonEntry(id: 'film-entry', mediaId: film.id),
        late,
      ],
      media: {season.id: season, film.id: film},
    );
    final restored = MarathonDefinition.fromJson(
      definition.id,
      definition.toJson(),
    );
    expect(restored.entries.map((e) => e.id), ['early', 'film-entry', 'late']);
    final progress = RunProgress({
      'early': {'ep-1', 'ep-2'},
    });
    expect(progress.isComplete(early, season), isTrue);
    expect(progress.isComplete(late, season), isFalse);
    expect(progress.count(late, season), 0);
  });
  test('repeated movies use separate list-entry identities', () {
    final media = release.media['lion-king-1994']!;
    final a = MarathonEntry(id: 'first-viewing', mediaId: media.id);
    final b = MarathonEntry(id: 'second-viewing', mediaId: media.id);
    final progress = RunProgress({
      a.id: {media.id},
    });
    expect(progress.isComplete(a, media), isTrue);
    expect(progress.isComplete(b, media), isFalse);
  });
  test('empty, duplicate and nonexistent episode selections are rejected', () {
    expect(
      () => MarathonEntry(id: 'x', mediaId: season.id, episodeIds: []),
      throwsArgumentError,
    );
    expect(
      () => MarathonEntry(
        id: 'x',
        mediaId: season.id,
        episodeIds: ['ep-1', 'ep-1'],
      ),
      throwsArgumentError,
    );
    expect(
      () => MarathonEntry(
        id: 'x',
        mediaId: season.id,
        episodeIds: ['missing'],
      ).units(season),
      throwsArgumentError,
    );
  });
  test('duplicate entry identities cannot silently merge progress', () {
    final a = MarathonEntry(id: 'same', mediaId: season.id);
    expect(
      () => MarathonDefinition(
        id: 'bad',
        title: 'Bad',
        order: ViewingOrder.custom,
        entries: [a, a],
        media: {season.id: season},
      ),
      throwsArgumentError,
    );
  });
  test('full-season completion requires every episode', () {
    final entry = MarathonEntry(id: 'season', mediaId: season.id);
    expect(
      RunProgress({
        'season': {'ep-1'},
      }).isComplete(entry, season),
      isFalse,
    );
    final complete = RunProgress({
      'season': season.episodes.map((e) => e.id).toSet(),
    });
    expect(complete.isComplete(entry, season), isTrue);
    expect(RunProgress.fromJson(complete.toJson()).count(entry, season), 10);
  });
  test('video games preserve play-time and release metadata', () {
    final game = CatalogMedia(
      id: 'game',
      universeId: 'private',
      kind: MediaKind.game,
      title: 'Example game',
      releaseDate: '2026-09-08',
      runtimeMinutes: 90,
      director: 'Example director',
      blurb: 'A game',
      poster: 'https://example.com/poster.jpg',
    );
    final restored = CatalogMedia.fromJson(game.toJson());
    expect(restored.kind, MediaKind.game);
    expect(restored.durationLabel, '1h 30m average play time');
    expect(restored.releaseDate, '2026-09-08');
    expect(restored.director, 'Example director');
  });
  test('year-only legacy dates do not pretend to be exact release dates', () {
    expect(release.media['lion-king-1994']!.releaseDate, isNull);
    expect(release.media['lion-king-1994']!.dateLabel, '1994');
  });
  test('Pixar chronology cannot accidentally contain Lion King titles', () {
    expect(
      universeMarathon(pixarConfig, ViewingOrder.chronological).entries,
      isEmpty,
    );
    expect(
      universeMarathon(
        pixarConfig,
        ViewingOrder.release,
      ).media.values.every((m) => m.universeId == 'pixar'),
      isTrue,
    );
  });
}
