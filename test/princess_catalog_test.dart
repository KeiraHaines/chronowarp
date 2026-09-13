import 'dart:convert';
import 'dart:io';
import 'package:chronowarp/data/princess_data.dart';
import 'package:chronowarp/data/marathon_catalog.dart';
import 'package:chronowarp/data/universe_configs.dart';
import 'package:chronowarp/models/marathon.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('all 43 source entries form one complete watch list', () {
    final provenance = jsonDecode(
      File('docs/princess-catalog-sources.json').readAsStringSync(),
    );
    expect(
      (provenance['records'] as List).map((r) => r['sourceStep']).toSet(),
      {for (var i = 1; i <= 43; i++) i},
    );
    expect(princessConfig.hasMultipleOrders, isFalse);
    final list = universeMarathon(princessConfig, ViewingOrder.release);
    expect(list.entries.length, 54);
    expect(
      princessCatalog.values.where((m) => m.kind == MediaKind.movie).length,
      34,
    );
    expect(
      princessCatalog.values.fold<int>(0, (n, m) => n + m.episodes.length),
      381,
    );
    expect(
      universeMarathon(princessConfig, ViewingOrder.chronological).id,
      list.id,
    );
    expect(
      list.media[list.entries.first.mediaId]!.title,
      'Snow White and the Seven Dwarfs',
    );
    expect(
      list.media[list.entries.last.mediaId]!.title,
      'Raya and the Last Dragon',
    );
    expect(availableUniverses, contains(princessConfig));
  });
  test('remakes and animated originals keep separate identities', () {
    for (final title in [
      'Cinderella',
      'Aladdin',
      'Mulan',
      'The Little Mermaid',
      'Beauty and the Beast',
    ]) {
      final films = princessCatalog.values
          .where((m) => m.title == title && m.kind == MediaKind.movie)
          .toList();
      expect(films.length, 2);
      expect(films.map((m) => m.id).toSet().length, 2);
      expect(films.map((m) => m.releaseYear).toSet().length, 2);
    }
    expect(
      princessCatalog['disney-princess-tmdb-movie-420817']!.releaseYear,
      2019,
    );
  });
  test('Elena finale is separate and shorts do not duplicate seasons', () {
    final season = princessCatalog['disney-princess-tmdb-tv-67175-season-3']!;
    expect(season.episodes.length, 27);
    expect(season.episodes.any((e) => e.title == 'Coronation Day'), isFalse);
    expect(
      princessCatalog['disney-princess-elena-coronation-day']!.runtimeMinutes,
      isNull,
    );
    expect(
      princessCatalog.values
          .where((m) => m.id.contains('-collection-'))
          .map((m) => m.episodes.length),
      [5, 5, 5, 5],
    );
  });
}
