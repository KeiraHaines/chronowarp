import 'package:chronowarp/data/marathon_catalog.dart';
import 'package:chronowarp/data/universe_configs.dart';
import 'package:chronowarp/models/marathon.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test(
    'Middle-earth orders share six films and put each trilogy correctly',
    () {
      final release = universeMarathon(
        lordOfTheRingsConfig,
        ViewingOrder.release,
      );
      final chrono = universeMarathon(
        lordOfTheRingsConfig,
        ViewingOrder.chronological,
      );
      expect(release.entries.length, 6);
      expect(chrono.entries.length, 6);
      expect(
        release.entries.map((e) => e.mediaId).toSet(),
        chrono.entries.map((e) => e.mediaId).toSet(),
      );
      expect(lordOfTheRingsConfig.releaseItems.map((m) => m.year), [
        2001,
        2002,
        2003,
        2012,
        2013,
        2014,
      ]);
      expect(lordOfTheRingsConfig.chronologicalItems.map((m) => m.year), [
        2012,
        2013,
        2014,
        2001,
        2002,
        2003,
      ]);
      expect(availableUniverses, contains(lordOfTheRingsConfig));
      expect(universeConfigFor('The Lord of the Rings'), lordOfTheRingsConfig);
    },
  );
}
