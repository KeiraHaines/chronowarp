import 'package:chronowarp/models/media_item.dart';
import 'package:chronowarp/widgets/media_rating_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets(
    'sheet averages selected categories and saves only on confirmation',
    (tester) async {
      await tester.binding.setSurfaceSize(const Size(390, 844));
      addTearDown(() => tester.binding.setSurfaceSize(null));
      CategoryRating? saved;
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) => Scaffold(
              body: TextButton(
                child: const Text('Rate'),
                onPressed: () => showMediaRatingSheet(
                  context: context,
                  title: 'The Lion King',
                  initialRating: const CategoryRating(story: 8),
                  onSave: (rating) => saved = rating,
                  bgCard: Colors.black,
                  bgChip: Colors.grey,
                  textCard: Colors.white,
                  textCardMuted: Colors.grey,
                  accentPrimary: Colors.green,
                  accentSecondary: Colors.yellow,
                ),
              ),
            ),
          ),
        ),
      );
      await tester.tap(find.text('Rate'));
      await tester.pumpAndSettle();
      expect(find.text('Save — 8.0/10'), findsOneWidget);
      // First two outline stars finish Story; the next ten belong to Acting.
      await tester.tap(find.byIcon(Icons.star_outline_rounded).at(5));
      await tester.pumpAndSettle();
      expect(find.text('Save — 6.0/10'), findsOneWidget);
      expect(saved, isNull);
      await tester.tap(find.text('Save — 6.0/10'));
      await tester.pumpAndSettle();
      expect(saved?.story, 8);
      expect(saved?.acting, 4);
      expect(saved?.sound, isNull);
      expect(find.text('The Lion King'), findsNothing);
      expect(tester.takeException(), isNull);
    },
  );
}
