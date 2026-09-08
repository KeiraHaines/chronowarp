import 'dart:typed_data';
import 'package:chronowarp/data/marathon_catalog.dart';
import 'package:chronowarp/models/marathon.dart';
import 'package:chronowarp/pages/create_marathon_page.dart';
import 'package:chronowarp/pages/custom_media_page.dart';
import 'package:chronowarp/pages/marathon_media_picker_page.dart';
import 'package:chronowarp/services/marathon_photo_store.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:image/image.dart' as img;

void main() {
  testWidgets(
    'Create starts at name and cover and preserves name when going back',
    (tester) async {
      await tester.pumpWidget(const MaterialApp(home: CreateMarathonPage()));
      expect(find.text('Marathon name'), findsOneWidget);
      expect(find.text('Choose a photo from your phone'), findsOneWidget);
      expect(find.text('Add new entry'), findsNothing);
      await tester.tap(find.text('Next: add entries'));
      await tester.pumpAndSettle();
      expect(find.text('Give your marathon a name'), findsOneWidget);
      await tester.enterText(find.byType(TextFormField), 'Weekend favourites');
      await tester.tap(find.text('Next: add entries'));
      await tester.pumpAndSettle();
      expect(find.text('Add new entry'), findsOneWidget);
      expect(find.text('Add existing item'), findsOneWidget);
      await tester.tap(find.byTooltip('Edit name and cover'));
      await tester.pumpAndSettle();
      expect(find.text('Weekend favourites'), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('existing media searches universes, titles and episode names', (
    tester,
  ) async {
    final library = {
      for (final config in availableUniverses) ...catalogFor(config),
    };
    await tester.pumpWidget(
      MaterialApp(home: MarathonMediaPickerPage(library: library)),
    );
    await tester.enterText(find.byType(TextField), 'lion Makuu');
    await tester.pumpAndSettle();
    expect(find.text('The Lion Guard — Season 1'), findsOneWidget);
    expect(find.text('Toy Story'), findsNothing);
    await tester.enterText(find.byType(TextField), 'Pixar Toy Story');
    await tester.pumpAndSettle();
    expect(find.text('Toy Story'), findsOneWidget);
    await tester.enterText(find.byType(TextField), 'no-such-item-123');
    await tester.pumpAndSettle();
    expect(find.textContaining('No matching items'), findsOneWidget);
  });

  testWidgets(
    'media fields use disappearing hints and a calendar date picker',
    (tester) async {
      await tester.pumpWidget(const MaterialApp(home: CustomMediaPage()));
      final title = find.byWidgetPredicate(
        (w) => w is TextField && w.decoration?.hintText == 'Title',
      );
      await tester.enterText(title, 'My film');
      expect(tester.widget<TextField>(title).decoration?.labelText, isNull);
      final date = find.byWidgetPredicate(
        (w) => w is TextField && w.decoration?.hintText == 'Release date',
      );
      expect(tester.widget<TextField>(date).readOnly, isTrue);
      await tester.tap(date);
      await tester.pumpAndSettle();
      expect(find.byType(DatePickerDialog), findsOneWidget);
      await tester.tap(find.text(DateTime.now().year.toString()).last);
      await tester.pumpAndSettle();
      await tester.tap(find.text('OK'));
      await tester.pumpAndSettle();
      expect(tester.widget<TextField>(date).controller!.text, isNotEmpty);
      expect(find.textContaining('HTTPS'), findsNothing);
      expect(tester.takeException(), isNull);
    },
  );

  test('photo compression creates a bounded JPEG and rejects invalid data', () {
    final source = img.Image(width: 1400, height: 900);
    for (final pixel in source) {
      pixel.setRgb(
        (pixel.x * 71 + pixel.y * 43) % 256,
        (pixel.x * 29) % 256,
        (pixel.y * 83) % 256,
      );
    }
    final compressed = compressMarathonPhoto(img.encodePng(source));
    expect(compressed.length, lessThanOrEqualTo(MarathonPhotoStore.maxBytes));
    final decoded = img.decodeJpg(compressed)!;
    expect(decoded.width, lessThanOrEqualTo(1000));
    expect(decoded.height, lessThanOrEqualTo(1000));
    expect(
      () => compressMarathonPhoto(Uint8List.fromList([1, 2, 3])),
      throwsFormatException,
    );
  });

  test('photo references fit existing private media snapshots', () {
    final media = CatalogMedia(
      id: 'private-movie',
      universeId: 'private',
      kind: MediaKind.movie,
      title: 'My film',
      poster: MarathonPhotoStore.reference('private-movie'),
    );
    expect(
      CatalogMedia.fromJson(media.toJson()).poster,
      'firestore-photo:private-movie',
    );
  });
}
