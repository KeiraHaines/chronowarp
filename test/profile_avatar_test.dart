import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:chronowarp/widgets/profile_avatar.dart';

void main() {
  testWidgets('Lion King group opens for an existing selection', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(390, 844));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(
      const MaterialApp(
        home: AvatarPicker(initialAvatarId: 'lionking-pride-rock'),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('Pride Rock'), findsOneWidget);
    expect(find.text('Rafiki’s Simba'), findsOneWidget);
    expect(
      avatarAssetPath('lionking-lion-guard'),
      'assets/avatars/lionking/lion-guard.png',
    );
    await tester.tap(find.text('Marvel'));
    await tester.pumpAndSettle();
    expect(find.text('Avengers'), findsOneWidget);
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
    await tester.tap(find.text('Avengers'));
    await tester.pumpAndSettle();
    expect(result, isNull);
    await tester.tap(find.text('Use avatar'));
    await tester.pumpAndSettle();
    expect(result, 'marvel-avengers');
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
