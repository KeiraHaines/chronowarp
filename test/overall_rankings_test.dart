import 'package:chronowarp/data/universe_configs.dart';
import 'package:chronowarp/models/media_item.dart';
import 'package:chronowarp/pages/overall_ranking_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets(
    'new universes appear in overall rankings and category sort changes',
    (tester) async {
      final a = lordOfTheRingsConfig.releaseItems.first;
      final b = princessConfig.releaseItems.first;
      final oldA = a.categoryRating, oldB = b.categoryRating;
      addTearDown(() {
        a.categoryRating = oldA;
        b.categoryRating = oldB;
      });
      a.categoryRating = const CategoryRating(story: 9, acting: 5);
      b.categoryRating = const CategoryRating(story: 6, acting: 10);
      await tester.pumpWidget(const MaterialApp(home: OverallRankingsPage()));
      expect(find.text(a.title), findsOneWidget);
      expect(find.text(b.title), findsOneWidget);
      expect(
        tester.getTopLeft(find.text(b.title)).dy,
        lessThan(tester.getTopLeft(find.text(a.title)).dy),
      );
      await tester.tap(find.widgetWithText(Tab, 'Story'));
      await tester.pumpAndSettle();
      expect(
        tester.getTopLeft(find.text(a.title)).dy,
        lessThan(tester.getTopLeft(find.text(b.title)).dy),
      );
      expect(tester.takeException(), isNull);
    },
  );
}
