import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:chronowarp/widgets/profile_avatar.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  test('every selectable avatar and the new cover are bundled', () async {
    expect(wizardingAvatars.length, 7);
    expect(princessAvatars.length, 6);
    for (final group in avatarGroups.entries) {
      for (final key in group.value.keys) {
        final asset = avatarAssetPath('${group.key}-$key');
        expect(asset, isNotNull);
        expect((await rootBundle.load(asset!)).lengthInBytes, greaterThan(0));
      }
    }
    expect(
      (await rootBundle.load('assets/cards/wizarding-world.png')).lengthInBytes,
      greaterThan(0),
    );
  });
}
