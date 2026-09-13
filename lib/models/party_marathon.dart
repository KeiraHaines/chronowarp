import '../data/marathon_catalog.dart';
import '../data/universe_configs.dart';
import 'marathon.dart';
import 'media_item.dart';

class PartyMarathon {
  static MarathonDefinition definition(
    String partyId,
    Map<String, dynamic> party,
  ) {
    final saved = party['marathon'];
    if (saved is Map) {
      return MarathonDefinition.fromJson(
        partyId,
        Map<String, dynamic>.from(saved),
      );
    }
    final config = universeConfigFor(party['universeKey'] as String? ?? '');
    final template = config == null
        ? null
        : universeMarathon(config, ViewingOrder.release);
    return MarathonDefinition(
      id: partyId,
      title: party['title'] as String? ?? 'Watch party',
      order: ViewingOrder.custom,
      universeId: template?.universeId,
      entries: template?.entries ?? [],
      media: template?.media ?? {},
    );
  }

  /// Party ratings use legacy numbers as identities, never as display positions.
  static Map<String, int> numbers(
    MarathonDefinition definition,
    Map<String, dynamic> party,
  ) {
    final saved = party['entryNumbers'];
    if (saved is Map)
      return saved.map(
        (key, value) => MapEntry(key as String, (value as num).toInt()),
      );
    return {
      for (final (index, entry) in definition.entries.indexed)
        entry.id: index + 1,
    };
  }

  static Map<String, int> extendNumbers(
    Map<String, int> previous,
    MarathonDefinition edited,
  ) {
    final result = Map<String, int>.from(previous);
    var next = result.values.fold<int>(0, (max, n) => n > max ? n : max) + 1;
    for (final entry in edited.entries) {
      result.putIfAbsent(entry.id, () => next++);
    }
    return result;
  }

  static List<MediaItem> items(
    MarathonDefinition definition,
    Map<String, int> numbers,
  ) => [
    for (final entry in definition.entries)
      MediaItem(
        number: numbers[entry.id]!,
        title: definition.media[entry.mediaId]!.title,
        year: definition.media[entry.mediaId]!.releaseYear ?? 0,
        type: switch (definition.media[entry.mediaId]!.kind) {
          MediaKind.movie => MediaType.movie,
          MediaKind.season => MediaType.show,
          MediaKind.game => MediaType.game,
        },
        runtime: definition.media[entry.mediaId]!.durationLabel,
        episodes: definition.media[entry.mediaId]!.kind == MediaKind.season
            ? entry.units(definition.media[entry.mediaId]!).length
            : null,
        posterPath: definition.media[entry.mediaId]!.poster,
        blurb: definition.media[entry.mediaId]!.blurb,
      ),
  ];
}
