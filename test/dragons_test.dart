import 'package:chronowarp/data/marathon_catalog.dart';
import 'package:chronowarp/data/universe_configs.dart';
import 'package:chronowarp/models/marathon.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('Dragons orders preserve all movies and 118 unique episodes', () {
    final release = universeMarathon(dragonsConfig, ViewingOrder.release);
    final chrono = universeMarathon(dragonsConfig, ViewingOrder.chronological);
    expect(release.entries.length, 16);
    expect(
      release.entries.map((e) => e.mediaId).toSet(),
      chrono.entries.map((e) => e.mediaId).toSet(),
    );
    expect(
      release.media.values.where((m) => m.kind == MediaKind.movie).length,
      8,
    );
    final seasons = release.media.values.where(
      (m) => m.kind == MediaKind.season,
    );
    expect(seasons.length, 8);
    expect(
      seasons.expand((m) => m.episodes).map((e) => e.id).toSet().length,
      118,
    );
    final dates = release.entries
        .map((e) => release.media[e.mediaId]!.releaseDate!)
        .toList();
    expect(dates, [...dates]..sort());
    final titles = chrono.entries
        .map((e) => chrono.media[e.mediaId]!.title)
        .toList();
    expect(
      titles.indexOf('Dragons: Race to the Edge — Season 6'),
      lessThan(titles.indexOf('How to Train Your Dragon 2')),
    );
    expect(availableUniverses, contains(dragonsConfig));
    expect(universeConfigFor('How to Train Your Dragon'), dragonsConfig);
  });
}
