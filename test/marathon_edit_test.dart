import 'package:chronowarp/models/marathon.dart';
import 'package:chronowarp/pages/create_marathon_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets(
    'editing reorders stable entries and saves the same universe run',
    (tester) async {
      final first = CatalogMedia(
        id: 'first',
        universeId: 'sample',
        kind: MediaKind.movie,
        title: 'First film',
      );
      final second = CatalogMedia(
        id: 'second',
        universeId: 'sample',
        kind: MediaKind.game,
        title: 'Second game',
      );
      final initial = MarathonDefinition(
        id: 'sample-release-v1',
        title: 'Sample',
        universeId: 'sample',
        order: ViewingOrder.release,
        entries: [
          MarathonEntry(id: 'first-occurrence-1', mediaId: first.id),
          MarathonEntry(id: 'second-occurrence-1', mediaId: second.id),
        ],
        media: {first.id: first, second.id: second},
      );
      MarathonDefinition? saved;
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) => Scaffold(
              body: TextButton(
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => MarathonDraftPage(
                      initialMarathon: initial,
                      saveChanges: (definition) async {
                        saved = definition;
                      },
                    ),
                  ),
                ),
                child: const Text('Open editor'),
              ),
            ),
          ),
        ),
      );
      await tester.tap(find.text('Open editor'));
      await tester.pumpAndSettle();
      expect(find.text('Edit order and entries'), findsOneWidget);
      expect(find.byTooltip('Edit name and cover'), findsNothing);
      final start = tester.getCenter(find.byIcon(Icons.drag_handle).first);
      final end =
          tester.getCenter(find.text('2. Second game')) + const Offset(0, 35);
      final gesture = await tester.startGesture(start);
      await gesture.moveBy(const Offset(0, 5));
      await tester.pump();
      await gesture.moveTo(end);
      await tester.pump(const Duration(milliseconds: 300));
      await gesture.moveBy(const Offset(0, 80));
      await tester.pump(const Duration(milliseconds: 600));
      await gesture.up();
      await tester.pumpAndSettle();
      expect(find.text('1. Second game'), findsOneWidget);
      await tester.tap(find.text('Save changes'));
      await tester.pumpAndSettle();
      expect(saved!.id, initial.id);
      expect(saved!.order, ViewingOrder.release);
      expect(saved!.universeId, 'sample');
      expect(saved!.entries.map((e) => e.id), [
        'second-occurrence-1',
        'first-occurrence-1',
      ]);
      expect(initial.entries.first.mediaId, first.id);
      final progress = RunProgress({
        'first-occurrence-1': {'first'},
      });
      expect(progress.isComplete(saved!.entries.last, first), isTrue);
      expect(progress.isComplete(saved!.entries.first, second), isFalse);
      expect(tester.takeException(), isNull);
    },
  );
}
