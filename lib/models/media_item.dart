enum MediaType { movie, show }

/// Stores the user's per-category ratings for a single entry.
class CategoryRating {
  final double? story;
  final double? acting;
  final double? action;
  final double? visuals;
  final double? sound;

  const CategoryRating({
    this.story,
    this.acting,
    this.action,
    this.visuals,
    this.sound,
  });

  double? get average {
    final filled = [
      story,
      acting,
      action,
      visuals,
      sound,
    ].whereType<double>().toList();
    if (filled.isEmpty) return null;
    return filled.reduce((a, b) => a + b) / filled.length;
  }

  CategoryRating copyWith({
    double? story,
    double? acting,
    double? action,
    double? visuals,
    double? sound,
  }) {
    return CategoryRating(
      story: story ?? this.story,
      acting: acting ?? this.acting,
      action: action ?? this.action,
      visuals: visuals ?? this.visuals,
      sound: sound ?? this.sound,
    );
  }
}

class MediaItem {
  final int number;

  /// Display title.
  /// Movies:      'Iron Man'
  /// Show season: 'Timon & Pumbaa — Season 1'
  final String title;

  final int year;
  final MediaType type;

  // ── Movie-only ────────────────────────────────────────────────────────────
  final String? runtime;

  // ── Show season fields ────────────────────────────────────────────────────

  /// Total episodes in this season.
  final int? episodes;

  /// Optional — when only a subset of episodes are required (e.g. MCU tie-in
  /// episodes). Displayed instead of the full episode count.
  /// Format: 'S1 E1–E5'  or  'S2 E3, E7–E9'
  final String? episodeRange;

  // ── Shared optional fields ────────────────────────────────────────────────
  final String? posterPath;
  final String? blurb;

  /// User's per-category rating. Mutable so it can be updated in place.
  CategoryRating? categoryRating;

  MediaItem({
    required this.number,
    required this.title,
    required this.year,
    required this.type,
    this.runtime,
    this.episodes,
    this.episodeRange,
    this.posterPath,
    this.blurb,
    this.categoryRating,
  });

  bool get isShow => type == MediaType.show;

  /// Derived overall rating from category scores.
  double? get rating => categoryRating?.average;
}
