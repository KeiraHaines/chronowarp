import 'marathon.dart';

class WatchStats {
  final int movies;
  final int episodes;
  const WatchStats({required this.movies, required this.episodes});

  /// Profile totals count unique media, independent of order and list position.
  factory WatchStats.calculate(
    Iterable<MarathonDefinition> definitions,
    Map<String, RunProgress> runs,
  ) {
    final movies = <String>{};
    final episodes = <(String, String)>{};
    for (final definition in definitions) {
      final progress = runs[definition.id];
      if (progress == null) continue;
      for (final entry in definition.entries) {
        final media = definition.media[entry.mediaId];
        if (media == null) continue;
        if (media.kind == MediaKind.movie &&
            progress.isComplete(entry, media)) {
          movies.add(media.id);
        } else if (media.kind == MediaKind.season) {
          for (final unit in entry.units(media)) {
            if (progress.completed[entry.id]?.contains(unit) ?? false) {
              episodes.add((media.id, unit));
            }
          }
        }
      }
    }
    return WatchStats(movies: movies.length, episodes: episodes.length);
  }
}
