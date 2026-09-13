import 'package:chronowarp/data/marathon_catalog.dart';
import 'package:chronowarp/data/universe_configs.dart';
import 'package:chronowarp/models/marathon.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('Indiana Jones orders share five films with distinct opening order', () {
    final release = universeMarathon(indianaJonesConfig, ViewingOrder.release);
    final chrono = universeMarathon(
      indianaJonesConfig,
      ViewingOrder.chronological,
    );
    expect(release.entries.length, 5);
    expect(chrono.entries.length, 5);
    expect(
      release.entries.map((e) => e.mediaId).toSet(),
      chrono.entries.map((e) => e.mediaId).toSet(),
    );
    expect(indianaJonesConfig.releaseItems.map((m) => m.year), [
      1981,
      1984,
      1989,
      2008,
      2023,
    ]);
    expect(indianaJonesConfig.chronologicalItems.map((m) => m.year), [
      1984,
      1981,
      1989,
      2008,
      2023,
    ]);
    expect(availableUniverses, contains(indianaJonesConfig));
    expect(universeConfigFor('Indiana Jones'), indianaJonesConfig);
  });
}
