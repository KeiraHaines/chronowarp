import 'package:chronowarp/data/marathon_catalog.dart';
import 'package:chronowarp/data/universe_configs.dart';
import 'package:chronowarp/models/marathon.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test(
    'Pixar uses its existing list and progress identity for either entry point',
    () {
      expect(pixarConfig.hasMultipleOrders, isFalse);
      final release = universeMarathon(pixarConfig, ViewingOrder.release);
      final alternate = universeMarathon(
        pixarConfig,
        ViewingOrder.chronological,
      );
      expect(release.entries, isNotEmpty);
      expect(alternate.toJson(), release.toJson());
      expect(alternate.id, 'pixar-release-v1');
    },
  );
  test('universes with a chronology keep independent orders', () {
    for (final config in [
      marvelConfig,
      starWarsConfig,
      lionKingConfig,
      wizardingWorldConfig,
    ]) {
      expect(config.hasMultipleOrders, isTrue);
      expect(
        universeMarathon(config, ViewingOrder.release).id,
        isNot(universeMarathon(config, ViewingOrder.chronological).id),
      );
    }
  });
}
