import 'dart:convert';
import 'package:chronowarp/data/marathon_catalog.dart';
import 'package:chronowarp/data/starwars_data.dart';
import 'package:chronowarp/data/universe_configs.dart';
import 'package:chronowarp/models/marathon.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final release = universeMarathon(starWarsConfig, ViewingOrder.release);
  final chrono = universeMarathon(starWarsConfig, ViewingOrder.chronological);
  MarathonEntry segment(int step, [int part = 1]) => chrono.entries.firstWhere(
    (e) => e.id == 'star-wars-chrono-source-$step-part-$part',
  );
  test('all source steps and units survive import', () {
    expect(release.entries.length, 63);
    expect(chrono.entries.length, 102);
    expect(
      chrono.entries
          .map((e) => int.parse(RegExp(r'source-(\d+)').firstMatch(e.id)![1]!))
          .toSet(),
      {for (var i = 1; i <= 72; i++) i},
    );
    final expected = {
      for (final e in release.entries) ...e.units(release.media[e.mediaId]!),
    };
    final actual = [
      for (final e in chrono.entries) ...e.units(chrono.media[e.mediaId]!),
    ];
    expect(actual.toSet(), expected);
    expect(actual.length, expected.length + 1);
    final repeated = actual.toSet().where(
      (u) => actual.where((v) => v == u).length > 1,
    );
    expect(repeated, ['star-wars-tmdb-tv-3122-season-3-ep-2']);
    expect(
      starWarsCatalog.values.fold<int>(0, (n, m) => n + m.episodes.length),
      542,
    );
  });
  test('release order is dated then explicitly undated', () {
    final dates = release.entries
        .map((e) => release.media[e.mediaId]!.releaseDate ?? '9999')
        .toList();
    expect(dates, [...dates]..sort());
    expect(
      release.media[release.entries.first.mediaId]!.title,
      'Star Wars: Episode IV - A New Hope',
    );
    expect(
      starWarsCatalog.values.where((m) => m.releaseDate == null).length,
      4,
    );
    for (final m in starWarsCatalog.values.where(
      (m) => m.releaseDate == null,
    )) {
      expect(m.releaseYear, isNull);
      expect(
        starWarsReleaseOrder.firstWhere((i) => i.catalogId == m.id).yearLabel,
        'TBA',
      );
    }
    final starfighter = starWarsCatalog.values.firstWhere(
      (m) => m.title == 'Star Wars: Starfighter',
    );
    expect(starfighter.releaseDate, '2027-05-28');
    expect(starfighter.runtimeMinutes, isNull);
  });
  test('source episode sequence and chapter corrections are preserved', () {
    final opening = segment(13);
    expect(
      opening.episodeIds!.map(
        (id) => chrono.media[opening.mediaId]!.episodes
            .firstWhere((e) => e.id == id)
            .number,
      ),
      [6, 7, 1, 2, 3, 4],
    );
    expect(segment(56, 2).episodeIds!.map((id) => id.split('-').last), [
      '1',
      '2',
      '3',
      '4',
    ]);
    expect(segment(58).episodeIds!.map((id) => id.split('-').last), [
      '5',
      '6',
      '7',
      '8',
    ]);
    expect(segment(25, 2).episodeIds!.length, 15);
    expect(segment(20).note, contains('15:25'));
    expect(segment(37).units(chrono.media[segment(37).mediaId]!).length, 4);
  });
  test('snapshots retain notes and episode selections', () {
    final encoded = jsonEncode(chrono.toJson());
    expect(utf8.encode(encoded).length, lessThan(750000));
    final restored = MarathonDefinition.fromJson(
      chrono.id,
      jsonDecode(encoded),
    );
    expect(restored.entries.length, 102);
    expect(
      restored.entries.firstWhere((e) => e.id == segment(20).id).note,
      segment(20).note,
    );
    expect(
      restored.entries.firstWhere((e) => e.id == segment(13).id).episodeIds,
      segment(13).episodeIds,
    );
  });
}
