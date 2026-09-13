import 'dart:convert';
import 'package:chronowarp/data/marathon_catalog.dart';
import 'package:chronowarp/data/marvel_data.dart';
import 'package:chronowarp/data/universe_configs.dart';
import 'package:chronowarp/models/marathon.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final release = universeMarathon(marvelConfig, ViewingOrder.release);
  final chronology = universeMarathon(marvelConfig, ViewingOrder.chronological);
  test('complete source imports as dated films and seasons', () {
    expect(release.entries.length, 102);
    expect(chronology.entries.length, 131);
    expect(
      marvelCatalog.values.where((m) => m.kind == MediaKind.movie).length,
      48,
    );
    expect(
      marvelCatalog.values.where((m) => m.kind == MediaKind.season).length,
      54,
    );
    expect(
      marvelCatalog.values.fold<int>(0, (n, m) => n + m.episodes.length),
      551,
    );
    final dates = release.entries
        .map((e) => release.media[e.mediaId]!.releaseDate!)
        .toList();
    expect(dates, [...dates]..sort());
    expect(release.media[release.entries.first.mediaId]!.title, 'Iron Man');
    expect(
      release.media[release.entries.last.mediaId]!.title,
      'Avengers: Doomsday',
    );
    expect(release.media[release.entries.last.mediaId]!.runtimeMinutes, isNull);
    expect(
      chronology.media[chronology.entries.first.mediaId]!.title,
      'Eyes of Wakanda — Season 1',
    );
  });
  test('all 120 source steps are retained and every episode occurs once', () {
    final sourceSteps = chronology.entries
        .map((e) => int.parse(RegExp(r'source-(\d+)').firstMatch(e.id)![1]!))
        .toSet();
    expect(sourceSteps, {for (var i = 1; i <= 120; i++) i});
    final expected = {
      for (final e in release.entries) ...e.units(release.media[e.mediaId]!),
    };
    final actual = [
      for (final e in chronology.entries)
        ...e.units(chronology.media[e.mediaId]!),
    ];
    expect(actual.toSet(), expected);
    expect(actual.length, expected.length);
    expect(release.media.keys.toSet(), chronology.media.keys.toSet());
  });
  test(
    'SHIELD episode segments preserve progress identity and precise selections',
    () {
      final early = chronology.entries.firstWhere(
        (e) => e.id == 'marvel-chrono-source-14-part-1',
      );
      final next = chronology.entries.firstWhere(
        (e) => e.id == 'marvel-chrono-source-16-part-1',
      );
      final media = chronology.media[early.mediaId]!;
      expect(early.mediaId, next.mediaId);
      expect(early.units(media).length, 7);
      expect(next.units(media).length, 5);
      expect(early.displayTitle(media), contains('Episodes 1–7'));
      final progress = RunProgress({early.id: early.units(media).toSet()});
      expect(progress.isComplete(early, media), isTrue);
      expect(progress.isComplete(next, media), isFalse);
      expect(media.episodes.first.title, isNotEmpty);
      expect(media.episodes.first.releaseDate, '2013-09-24');
    },
  );
  test(
    'release order uses original public release instead of streaming rerelease',
    () {
      final consultant = marvelCatalog.values.firstWhere(
        (m) => m.title == 'Marvel One-Shot: The Consultant',
      );
      expect(consultant.releaseDate, '2011-09-13');
    },
  );
  test('full chronology survives saved definition round trip', () {
    final encoded = jsonEncode(chronology.toJson());
    expect(utf8.encode(encoded).length, lessThan(750000));
    final restored = MarathonDefinition.fromJson(
      chronology.id,
      jsonDecode(encoded),
    );
    expect(restored.entries.length, 131);
    expect(restored.entries[3].episodeIds, chronology.entries[3].episodeIds);
    expect(restored.media.length, 102);
  });
}
