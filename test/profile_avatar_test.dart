import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:chronowarp/widgets/profile_avatar.dart';

void main() {
  testWidgets('Pixar avatars open for a saved selection on a small screen', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(360, 800));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(
      const MaterialApp(
        home: AvatarPicker(initialAvatarId: 'pixar-ball-badge'),
      ),
    );
    await tester.pumpAndSettle();
    for (final name in ['Star Ball', 'Rocket', 'Mike Wazowski']) {
      expect(find.text(name), findsOneWidget);
    }
    expect(
      avatarAssetPath('pixar-ball-badge'),
      'assets/avatars/pixar/ball-badge.png',
    );
    expect(tester.takeException(), isNull);
  });
  testWidgets('Star Wars selection opens its group on a narrow phone', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(360, 800));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(
      const MaterialApp(
        home: AvatarPicker(initialAvatarId: 'starwars-jedi-badge'),
      ),
    );
    await tester.pumpAndSettle();
    for (final name in ['Jedi Order', 'Galactic Empire', 'Rebel Alliance']) {
      expect(find.text(name), findsOneWidget);
    }
    expect(
      avatarAssetPath('starwars-empire-badge'),
      'assets/avatars/starwars/empire-badge.png',
    );
    await tester.tap(find.text('Galactic Empire'));
    await tester.pumpAndSettle();
    expect(
      tester
          .widget<SegmentedButton<String>>(find.byType(SegmentedButton<String>))
          .selected,
      {'starwars'},
    );
    expect(tester.takeException(), isNull);
  });
  testWidgets('Lion King group opens for an existing selection', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(390, 844));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(
      const MaterialApp(
        home: AvatarPicker(initialAvatarId: 'lionking-pride-rock-badge'),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('Pride Rock'), findsOneWidget);
    expect(find.text('Simba'), findsOneWidget);
    expect(
      avatarAssetPath('lionking-scar-badge'),
      'assets/avatars/lionking/scar-badge.png',
    );
    await tester.tap(find.text('Marvel'));
    await tester.pumpAndSettle();
    expect(find.text('Iron Man'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
  testWidgets('avatar choice returns a stable id only after confirmation', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(390, 844));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    String? result;
    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) => TextButton(
            onPressed: () async {
              result = await Navigator.push<String>(
                context,
                MaterialPageRoute(builder: (_) => const AvatarPicker()),
              );
            },
            child: const Text('Open'),
          ),
        ),
      ),
    );
    await tester.tap(find.text('Open'));
    await tester.pumpAndSettle();
    expect(
      tester.widget<FilledButton>(find.byType(FilledButton)).onPressed,
      isNull,
    );
    await tester.tap(find.text('Iron Man'));
    await tester.pumpAndSettle();
    expect(result, isNull);
    await tester.tap(find.text('Use avatar'));
    await tester.pumpAndSettle();
    expect(result, 'marvel-iron-man-badge');
    expect(tester.takeException(), isNull);
  });
  testWidgets('unknown avatar keeps initials fallback', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: ProfileAvatar(name: 'Keira', avatarId: 'missing'),
      ),
    );
    expect(find.text('K'), findsOneWidget);
  });
}
