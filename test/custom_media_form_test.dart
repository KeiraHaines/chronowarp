import 'package:chronowarp/pages/custom_media_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('season and game forms expose the correct metadata', (
    tester,
  ) async {
    await tester.pumpWidget(const MaterialApp(home: CustomMediaPage()));
    await tester.pumpAndSettle();
    expect(find.text('Runtime (minutes)'), findsOneWidget);
    await tester.tap(find.text('Movie').last);
    await tester.pumpAndSettle();
    await tester.tap(find.text('TV show — one season').last);
    await tester.pumpAndSettle();
    expect(find.text('TV show name'), findsOneWidget);
    expect(find.text('Season number'), findsOneWidget);
    expect(find.text('Number of episodes'), findsOneWidget);
    expect(tester.takeException(), isNull);
    await tester.tap(find.text('TV show — one season').last);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Video game').last);
    await tester.pumpAndSettle();
    expect(find.text('Average play time (minutes)'), findsOneWidget);
    expect(find.text('Number of episodes'), findsNothing);
    expect(tester.takeException(), isNull);
  });
}
