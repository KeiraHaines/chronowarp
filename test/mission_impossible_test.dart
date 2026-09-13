import 'package:chronowarp/data/marathon_catalog.dart';
import 'package:chronowarp/data/universe_configs.dart';
import 'package:chronowarp/models/marathon.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('Mission Impossible has one ordered eight-film list', () {
    final list = universeMarathon(
      missionImpossibleConfig,
      ViewingOrder.release,
    );
    expect(list.entries.length, 8);
    expect(list.entries.map((e) => e.mediaId).toSet().length, 8);
    expect(missionImpossibleConfig.releaseItems.map((m) => m.year), [
      1996,
      2000,
      2006,
      2011,
      2015,
      2018,
      2023,
      2025,
    ]);
    expect(missionImpossibleConfig.hasMultipleOrders, isFalse);
    expect(
      universeMarathon(missionImpossibleConfig, ViewingOrder.chronological).id,
      list.id,
    );
    expect(availableUniverses, contains(missionImpossibleConfig));
    expect(universeConfigFor('Mission: Impossible'), missionImpossibleConfig);
  });
}
