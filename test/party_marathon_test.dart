import 'package:chronowarp/models/party_marathon.dart';
import 'package:chronowarp/models/marathon.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final party = <String, dynamic>{
    'universeKey': 'Wizarding World',
    'title': 'Movie night',
  };
  test('legacy parties retain their original watched and rating numbers', () {
    final original = PartyMarathon.definition('party', party);
    final numbers = PartyMarathon.numbers(original, party);
    expect(original.entries.length, 12);
    expect(numbers[original.entries.first.id], 1);
    final edited = MarathonDefinition(
      id: original.id,
      title: original.title,
      order: ViewingOrder.custom,
      entries: original.entries.reversed.toList(),
      media: original.media,
    );
    final after = PartyMarathon.extendNumbers(numbers, edited);
    final items = PartyMarathon.items(edited, after);
    expect(items.first.number, 12);
    expect(items.last.number, 1);
    expect(items.last.title, "Harry Potter and the Philosopher's Stone");
  });
  test(
    'new entries never reuse removed item numbers and saved order round trips',
    () {
      final original = PartyMarathon.definition('party', party);
      final numbers = PartyMarathon.numbers(original, party);
      final newEntry = MarathonEntry(
        id: 'new-occurrence',
        mediaId: original.entries.first.mediaId,
      );
      final edited = MarathonDefinition(
        id: 'party',
        title: 'Edited night',
        order: ViewingOrder.custom,
        entries: [original.entries[1], newEntry],
        media: original.media,
      );
      final after = PartyMarathon.extendNumbers(numbers, edited);
      expect(after[newEntry.id], 13);
      expect(after[original.entries.first.id], 1);
      final saved = {
        ...party,
        'marathon': edited.toJson(),
        'entryNumbers': after,
      };
      final restored = PartyMarathon.definition('party', saved);
      expect(restored.title, 'Edited night');
      expect(
        restored.entries.map((e) => e.id),
        edited.entries.map((e) => e.id),
      );
      expect(PartyMarathon.numbers(restored, saved), after);
    },
  );
}
