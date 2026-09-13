import 'package:chronowarp/data/marathon_catalog.dart';
import 'package:chronowarp/data/universe_configs.dart';
import 'package:chronowarp/models/marathon.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('Pirates has one five-film watchlist in release order', () {
    final list = universeMarathon(piratesConfig, ViewingOrder.release);
    expect(list.entries.length, 5);
    expect(list.entries.map((e) => e.mediaId).toSet().length, 5);
    expect(piratesConfig.releaseItems.map((m) => m.year), [
      2003,
      2006,
      2007,
      2011,
      2017,
    ]);
    expect(piratesConfig.hasMultipleOrders, isFalse);
    expect(
      universeMarathon(piratesConfig, ViewingOrder.chronological).id,
      list.id,
    );
    expect(availableUniverses, contains(piratesConfig));
    expect(universeConfigFor('Pirates of the Caribbean'), piratesConfig);
    expect(
      list.media[list.entries.last.mediaId]!.director,
      'Joachim Rønning, Espen Sandberg',
    );
  });
}
