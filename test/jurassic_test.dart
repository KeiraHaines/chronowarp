import 'package:chronowarp/data/marathon_catalog.dart';
import 'package:chronowarp/data/universe_configs.dart';
import 'package:chronowarp/models/marathon.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('Jurassic orders share nine films/shorts and 88 episodes', () {
    final r = universeMarathon(jurassicConfig, ViewingOrder.release);
    final c = universeMarathon(jurassicConfig, ViewingOrder.chronological);
    expect(r.entries.length, 18);
    expect(r.entries.map((e) => e.mediaId).toSet().length, 18);
    expect(
      r.entries.map((e) => e.mediaId).toSet(),
      c.entries.map((e) => e.mediaId).toSet(),
    );
    expect(r.media.values.where((m) => m.kind == MediaKind.movie).length, 9);
    expect(
      r.media.values.expand((m) => m.episodes).map((e) => e.id).toSet().length,
      88,
    );
    final prologue = r.media.values.singleWhere(
      (m) => m.title.contains('Prologue'),
    );
    expect(prologue.runtimeMinutes, 5);
    expect(prologue.releaseYear, 2021);
    final dates = r.entries
        .map((e) => r.media[e.mediaId]!.releaseDate!)
        .toList();
    expect(dates, [...dates]..sort());
    expect(availableUniverses, contains(jurassicConfig));
    expect(universeConfigFor('Jurassic World'), jurassicConfig);
  });
}
