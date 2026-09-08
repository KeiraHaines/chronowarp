import 'package:chronowarp/models/media_item.dart';
import 'package:flutter/foundation.dart';

/// Identifies a single watched unit:
/// - Movie/VideoGame: seasonNumber and episodeNumber are null
/// - TvShow full season: episodeNumber is null
/// - TvShow single episode: both are set
class WatchedEpisodeKey {
  final int seasonNumber;
  final int episodeNumber;

  const WatchedEpisodeKey({
    required this.seasonNumber,
    required this.episodeNumber,
  });

  @override
  bool operator ==(Object other) =>
      other is WatchedEpisodeKey &&
      other.seasonNumber == seasonNumber &&
      other.episodeNumber == episodeNumber;

  @override
  int get hashCode => Object.hash(seasonNumber, episodeNumber);
}

/// Tracks watched progress for a single TvShow (episode-level granularity).
class ShowProgress {
  // seasonNumber -> set of watched episodeNumbers
  final Map<int, Set<int>> _watchedEpisodes = {};

  Set<int> watchedEpisodesInSeason(int seasonNumber) =>
      _watchedEpisodes[seasonNumber] ?? <int>{};

  bool isEpisodeWatched(int seasonNumber, int episodeNumber) =>
      _watchedEpisodes[seasonNumber]?.contains(episodeNumber) ?? false;

  bool isSeasonFullyWatched(int seasonNumber, int totalEpisodes) {
    final watched = _watchedEpisodes[seasonNumber];
    if (watched == null) return false;
    return watched.length >= totalEpisodes;
  }

  void toggleEpisode(int seasonNumber, int episodeNumber) {
    final set = _watchedEpisodes.putIfAbsent(seasonNumber, () => <int>{});
    if (set.contains(episodeNumber)) {
      set.remove(episodeNumber);
    } else {
      set.add(episodeNumber);
    }
  }

  /// Mark all episodes in a season as watched/unwatched.
  void toggleSeason(int seasonNumber, List<int> allEpisodeNumbers) {
    final set = _watchedEpisodes.putIfAbsent(seasonNumber, () => <int>{});
    final allWatched = allEpisodeNumbers.every((ep) => set.contains(ep));
    if (allWatched) {
      set.removeAll(allEpisodeNumbers);
    } else {
      set.addAll(allEpisodeNumbers);
    }
  }

  int totalWatchedEpisodes() =>
      _watchedEpisodes.values.fold(0, (sum, s) => sum + s.length);
}

/// App-wide singleton store for all watch progress.
///
/// Movies and VideoGames are tracked by their item number (present/absent
/// in a Set<int>). TvShows are tracked at episode level via [ShowProgress].
class ProgressStore extends ChangeNotifier {
  ProgressStore._internal();
  static final ProgressStore instance = ProgressStore._internal();

  // ── Movie / VideoGame tracking (by item number) ───────────────────────────

  // universeKey -> set of watched item numbers
  final Map<String, Set<int>> _watched = {};

  Set<int> watchedFor(String universeKey) => _watched[universeKey] ?? <int>{};

  bool isWatched(String universeKey, int number) =>
      _watched[universeKey]?.contains(number) ?? false;

  void toggle(String universeKey, int number) {
    final set = _watched.putIfAbsent(universeKey, () => <int>{});
    if (set.contains(number)) {
      set.remove(number);
    } else {
      set.add(number);
    }
    notifyListeners();
  }

  // ── TV Show tracking (episode level) ─────────────────────────────────────

  // universeKey -> showNumber -> ShowProgress
  final Map<String, Map<int, ShowProgress>> _showProgress = {};

  ShowProgress _getShowProgress(String universeKey, int showNumber) {
    return _showProgress
        .putIfAbsent(universeKey, () => {})
        .putIfAbsent(showNumber, () => ShowProgress());
  }

  ShowProgress showProgressFor(String universeKey, int showNumber) =>
      _getShowProgress(universeKey, showNumber);

  bool isEpisodeWatched(
    String universeKey,
    int showNumber,
    int seasonNumber,
    int episodeNumber,
  ) => _getShowProgress(
    universeKey,
    showNumber,
  ).isEpisodeWatched(seasonNumber, episodeNumber);

  bool isSeasonFullyWatched(
    String universeKey,
    int showNumber,
    int seasonNumber,
    int totalEpisodes,
  ) => _getShowProgress(
    universeKey,
    showNumber,
  ).isSeasonFullyWatched(seasonNumber, totalEpisodes);

  void toggleEpisode(
    String universeKey,
    int showNumber,
    int seasonNumber,
    int episodeNumber,
  ) {
    _getShowProgress(
      universeKey,
      showNumber,
    ).toggleEpisode(seasonNumber, episodeNumber);
    notifyListeners();
  }

  void toggleSeason(
    String universeKey,
    int showNumber,
    int seasonNumber,
    List<int> allEpisodeNumbers,
  ) {
    _getShowProgress(
      universeKey,
      showNumber,
    ).toggleSeason(seasonNumber, allEpisodeNumbers);
    notifyListeners();
  }

  /// Total watched episodes across all seasons of a show.
  int totalWatchedEpisodesFor(String universeKey, int showNumber) =>
      _getShowProgress(universeKey, showNumber).totalWatchedEpisodes();

  /// Returns the next unwatched episode across all seasons in order,
  /// or null if everything is watched.
  /// Returns a record of (seasonNumber, episode).
  ({int seasonNumber, int episodeNumber, String episodeTitle})? nextEpisodeFor(
    String universeKey,
    int showNumber,
    List<Season> seasons, // import media_item.dart where Season is defined
  ) {
    final progress = _getShowProgress(universeKey, showNumber);
    for (final season in seasons) {
      for (final episode in season.episodes) {
        if (!progress.isEpisodeWatched(
          season.seasonNumber,
          episode.episodeNumber,
        )) {
          return (
            seasonNumber: season.seasonNumber,
            episodeNumber: episode.episodeNumber,
            episodeTitle: episode.title,
          );
        }
      }
    }
    return null; // all watched
  }
}
