import 'package:chronowarp/services/rating_store.dart';
import 'package:chronowarp/data/universe_configs.dart';
import 'package:chronowarp/data/marathon_catalog.dart';
import 'package:chronowarp/models/media_item.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  test(
    'ratings reload from storage, sync both orders, and isolate accounts',
    () async {
      SharedPreferences.setMockInitialValues({});
      await RatingStore.initialize();
      RatingStore.activate('alice');
      await RatingStore.save('private-game', const CategoryRating(story: 8, visuals: 6));
      expect(RatingStore.read('private-game')?.average, 7);
      final item = indianaJonesConfig.releaseItems.first;
      final id = mediaIdFor(universeIdFor(indianaJonesConfig.title), item);
      await RatingStore.save(id, const CategoryRating(story: 9, acting: 7));
      expect(item.rating, 8);
      RatingStore.activate(null);
      expect(item.rating, isNull);
      await RatingStore.initialize();
      RatingStore.activate('alice');
      expect(RatingStore.read('private-game')?.average, 7);
      expect(item.rating, 8);
      expect(indianaJonesConfig.chronologicalItems[1].rating, 8);
      RatingStore.activate('bob');
      expect(RatingStore.read('private-game'), isNull);
      expect(item.rating, isNull);
      await RatingStore.save(id, const CategoryRating(story: 5));
      RatingStore.activate('alice');
      expect(item.rating, 8);
      RatingStore.activate(null);
    },
  );
}
