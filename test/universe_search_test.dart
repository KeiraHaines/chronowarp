import 'package:chronowarp/pages/universe_search.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

const entries = [
  UniverseSearchEntry(
    title: 'Wizarding World',
    titles: ['Harry Potter and the Chamber of Secrets'],
  ),
  UniverseSearchEntry(title: 'The Lion King', titles: ['Mufasa']),
];
void main() {
  test(
    'custom marathons match names and contents without conflating duplicate names',
    () {
      const custom = UniverseSearchEntry(
        id: 'custom:123',
        title: 'The Lion King',
        isCustom: true,
        titles: ['Weekend game'],
      );
      expect(searchUniverses([...entries, custom], 'lion king').length, 2);
      expect(
        searchUniverses([...entries, custom], 'weekend game').single.id,
        'custom:123',
      );
    },
  );
  test(
    'search handles universe names, film titles, casing and empty queries',
    () {
      expect(
        searchUniverses(entries, '  WIZARDING ').single.title,
        'Wizarding World',
      );
      expect(
        searchUniverses(entries, 'harry potter').single.title,
        'Wizarding World',
      );
      expect(searchUniverses(entries, 'mufasa').single.title, 'The Lion King');
      expect(searchUniverses(entries, '').length, 2);
      expect(searchUniverses(entries, 'unknown'), isEmpty);
    },
  );
  testWidgets('search filters, clears and returns the chosen universe', (
    tester,
  ) async {
    String? selected;
    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) => Scaffold(
            body: TextButton(
              onPressed: () async {
                selected = await showSearch<String>(
                  context: context,
                  delegate: UniverseSearch(entries),
                );
              },
              child: const Text('Search'),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.text('Search'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), 'unknown');
    await tester.pumpAndSettle();
    expect(
      find.textContaining('No universes or marathons found'),
      findsOneWidget,
    );
    await tester.tap(find.byTooltip('Clear search'));
    await tester.pumpAndSettle();
    expect(find.text('The Lion King'), findsOneWidget);
    await tester.enterText(find.byType(TextField), 'harry');
    await tester.pumpAndSettle();
    await tester.tap(find.text('Wizarding World'));
    await tester.pumpAndSettle();
    expect(selected, 'Wizarding World');
  });
}
