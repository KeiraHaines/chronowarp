import 'package:chronowarp/data/marathon_catalog.dart';
import 'package:chronowarp/data/universe_configs.dart';
import 'package:chronowarp/models/marathon.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test(
    'X-Men preserves supplied chronology and sorts release ties correctly',
    () {
      final release = universeMarathon(xmenConfig, ViewingOrder.release);
      final chrono = universeMarathon(xmenConfig, ViewingOrder.chronological);
      expect(release.entries.length, 12);
      expect(chrono.entries.length, 12);
      expect(
        release.entries.map((e) => e.mediaId).toSet(),
        chrono.entries.map((e) => e.mediaId).toSet(),
      );
      expect(release.entries.map((e) => e.mediaId).toSet().length, 12);
      expect(xmenConfig.chronologicalItems.first.title, 'X-Men: First Class');
      expect(
        xmenConfig.chronologicalItems[1].title,
        'X-Men: Days of Future Past',
      );
      expect(xmenConfig.chronologicalItems.last.title, 'Logan');
      expect(xmenConfig.releaseItems.first.title, 'X-Men');
      expect(xmenConfig.releaseItems.last.title, 'X-Men: Dark Phoenix');
      expect(
        xmenConfig.releaseItems
            .where((m) => m.year == 2016)
            .map((m) => m.title),
        ['Deadpool', 'X-Men: Apocalypse'],
      );
      final years = xmenConfig.releaseItems.map((m) => m.year).toList();
      expect(years, [...years]..sort());
      expect(availableUniverses, contains(xmenConfig));
      expect(universeConfigFor('X-Men'), xmenConfig);
      expect(release.id, isNot(chrono.id));
    },
  );
}
