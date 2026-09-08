import '../models/marathon.dart';
import '../models/media_item.dart';
import 'universe_configs.dart';
import 'lionking_episodes.dart';
import '../widgets/universe_watch_page.dart';

String universeIdFor(String title) => switch (title) {
  'The Lion King' || 'Lion King' => 'lion-king',
  'Marvel Cinematic Universe' => 'marvel',
  'Pixar' => 'pixar',
  'Star Wars' || 'Star Wars Universe' => 'star-wars',
  _ => title.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]+'), '-'),
};

const _lionIds = {
  '1994:The Lion King': 'lion-king-1994',
  '1995:Timon & Pumbaa — Season 1': 'timon-pumbaa-s1',
  '1996:Timon & Pumbaa — Season 2': 'timon-pumbaa-s2',
  '1999:Timon & Pumbaa — Season 3': 'timon-pumbaa-s3',
  "1998:The Lion King II: Simba's Pride": 'lion-king-2',
  '2004:The Lion King 1½': 'lion-king-one-and-half',
  '2015:The Lion King: Return of the Roar': 'return-of-the-roar',
  '2016:The Lion Guard — Season 1': 'lion-guard-s1',
  '2017:The Lion Guard — Season 2': 'lion-guard-s2',
  '2017:The Lion Guard — Season 3': 'lion-guard-s3',
  "2016:It's UnBungalievable": 'unbungalievable-s1',
  '2019:The Lion King': 'lion-king-2019',
  '2024:Mufasa: The Lion King': 'mufasa-2024',
};

String mediaIdFor(String universe, MediaItem item) {
  if (universe == 'lion-king') return _lionIds['${item.year}:${item.title}']!;
  return '$universe-${item.year}-${item.title.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]+'), '-')}';
}

CatalogMedia _convert(String universe, MediaItem item) {
  final id = mediaIdFor(universe, item);
  final hour = int.tryParse(
    RegExp(r'(\d+)h').firstMatch(item.runtime ?? '')?.group(1) ?? '',
  );
  final minute = int.tryParse(
    RegExp(r'(\d+)m').firstMatch(item.runtime ?? '')?.group(1) ?? '',
  );
  final season = int.tryParse(
    RegExp(r'Season (\d+)').firstMatch(item.title)?.group(1) ?? '',
  );
  return CatalogMedia(
    id: id,
    universeId: universe,
    kind: item.isShow ? MediaKind.season : MediaKind.movie,
    title: item.title,
    releaseYear: item.year,
    runtimeMinutes: hour == null && minute == null
        ? null
        : (hour ?? 0) * 60 + (minute ?? 0),
    director: item is Movie ? item.director : null,
    blurb: item.blurb,
    poster: item.posterPath,
    showTitle: item.isShow ? item.title.split(' — Season').first : null,
    seasonNumber: item.isShow ? season ?? 1 : null,
    episodes:
        lionKingEpisodes[id] ??
        List.generate(
          item.episodes ?? 0,
          (i) => EpisodeRecord(id: '$id-ep-${i + 1}', number: i + 1),
        ),
  );
}

/// One catalogue record per title/season. Existing order lists remain curated
/// templates, not sources of identity. Legacy party item numbers remain intact.
Map<String, CatalogMedia> catalogFor(UniverseConfig config) {
  final universe = universeIdFor(config.title);
  return {
    for (final item in config.releaseItems)
      mediaIdFor(universe, item): _convert(universe, item),
  };
}

MarathonDefinition universeMarathon(UniverseConfig config, ViewingOrder order) {
  final universe = universeIdFor(config.title);
  final media = catalogFor(config);
  final items = order == ViewingOrder.release
      ? config.releaseItems
      : config.chronologicalItems;
  final occurrences = <String, int>{};
  final entries = items.map((item) {
    final id = mediaIdFor(universe, item);
    final count = occurrences.update(id, (v) => v + 1, ifAbsent: () => 1);
    return MarathonEntry(id: '$id-occurrence-$count', mediaId: id);
  }).toList();
  return MarathonDefinition(
    id: '$universe-${order.name}-v1',
    title: config.title,
    universeId: universe,
    order: order,
    entries: entries,
    media: media,
  );
}

List<UniverseConfig> get availableUniverses => [
  lionKingConfig,
  marvelConfig,
  pixarConfig,
  starWarsConfig,
];
