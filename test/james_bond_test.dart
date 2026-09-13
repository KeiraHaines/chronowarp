import 'package:chronowarp/data/marathon_catalog.dart';
import 'package:chronowarp/data/universe_configs.dart';
import 'package:chronowarp/models/marathon.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('Bond has one release list with 25 films and First Light as a game', () {
    final list = universeMarathon(jamesBondConfig, ViewingOrder.release);
    expect(jamesBondConfig.hasMultipleOrders, isFalse);
    expect(list.entries.length, 26);
    expect(list.entries.map((e) => e.mediaId).toSet().length, 26);
    expect(
      list.media.values.where((m) => m.kind == MediaKind.movie).length,
      25,
    );
    expect(list.media[list.entries.first.mediaId]!.title, 'Dr. No');
    final game = list.media[list.entries.last.mediaId]!;
    expect(game.title, '007 First Light');
    expect(game.kind, MediaKind.game);
    expect(game.developer, 'IO Interactive');
    expect(game.runtimeMinutes, isNull);
    expect(list.media[list.entries[6].mediaId]!.runtimeMinutes, 120);
    final years = jamesBondConfig.releaseItems.map((m) => m.year).toList();
    expect(years, [...years]..sort());
    expect(
      universeMarathon(jamesBondConfig, ViewingOrder.chronological).id,
      list.id,
    );
    expect(availableUniverses, contains(jamesBondConfig));
    expect(universeConfigFor('James Bond'), jamesBondConfig);
  });
}
