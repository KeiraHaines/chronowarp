/// Catalogue identity is independent of a title's position in any viewing list.
enum MediaKind { movie, season, game }

enum ViewingOrder { release, chronological, custom }

class EpisodeRecord {
  final String id;
  final int number;
  final String? imdbId;
  final String? title;
  final String? releaseDate;
  final int? runtimeMinutes;
  const EpisodeRecord({
    required this.id,
    required this.number,
    this.imdbId,
    this.title,
    this.releaseDate,
    this.runtimeMinutes,
  });
  String get label =>
      title == null || title!.isEmpty ? 'Episode $number' : '$number. $title';
  String get detailsLabel {
    final name = title?.trim();
    final episodeName = name == null || name.isEmpty
        ? '$number. Name not added yet'
        : '$number. $name';
    final duration = runtimeMinutes == null
        ? 'Duration not added yet'
        : '$runtimeMinutes min';
    return '$episodeName · $duration';
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'number': number,
    'imdbId': imdbId,
    'title': title,
    'releaseDate': releaseDate,
    'runtimeMinutes': runtimeMinutes,
  };
  factory EpisodeRecord.fromJson(Map<String, dynamic> j) => EpisodeRecord(
    id: j['id'] as String,
    number: j['number'] as int,
    imdbId: j['imdbId'] as String?,
    title: j['title'] as String?,
    releaseDate: j['releaseDate'] as String?,
    runtimeMinutes: j['runtimeMinutes'] as int?,
  );
}

class CatalogMedia {
  final String id;
  final String universeId;
  final MediaKind kind;
  final String title;

  /// ISO date, only populated when the complete date is known.
  final String? releaseDate;
  final int? releaseYear;

  /// For games this is average play time; for seasons average episode runtime.
  final int? runtimeMinutes;
  final String? director;
  final String? blurb;

  /// Flutter asset path or HTTPS image URL.
  final String? poster;
  final String? showTitle;
  final int? seasonNumber;
  final List<EpisodeRecord> episodes;
  CatalogMedia({
    required this.id,
    required this.universeId,
    required this.kind,
    required this.title,
    this.releaseDate,
    this.releaseYear,
    this.runtimeMinutes,
    this.director,
    this.blurb,
    this.poster,
    this.showTitle,
    this.seasonNumber,
    List<EpisodeRecord> episodes = const [],
  }) : episodes = List.unmodifiable(episodes) {
    if (id.isEmpty || title.trim().isEmpty)
      throw ArgumentError('Media needs an ID and title');
    if (kind != MediaKind.season && episodes.isNotEmpty)
      throw ArgumentError('Only seasons contain episodes');
    if (episodes.map((e) => e.id).toSet().length != episodes.length ||
        episodes.map((e) => e.number).toSet().length != episodes.length) {
      throw ArgumentError(
        'Episode IDs and numbers must be unique within a season',
      );
    }
  }
  String get dateLabel =>
      releaseDate ?? releaseYear?.toString() ?? 'Release date not added';
  String get durationLabel {
    if (runtimeMinutes == null)
      return kind == MediaKind.game
          ? 'Play time not added'
          : 'Runtime not added';
    final h = runtimeMinutes! ~/ 60, m = runtimeMinutes! % 60;
    final duration = [
      if (h > 0) '${h}h',
      if (m > 0 || h == 0) '${m}m',
    ].join(' ');
    return kind == MediaKind.game
        ? '$duration average play time'
        : kind == MediaKind.season
        ? '$duration per episode'
        : duration;
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'universeId': universeId,
    'kind': kind.name,
    'title': title,
    'releaseDate': releaseDate,
    'releaseYear': releaseYear,
    'runtimeMinutes': runtimeMinutes,
    'director': director,
    'blurb': blurb,
    'poster': poster,
    'showTitle': showTitle,
    'seasonNumber': seasonNumber,
    'episodes': episodes.map((e) => e.toJson()).toList(),
  };
  factory CatalogMedia.fromJson(Map<String, dynamic> j) => CatalogMedia(
    id: j['id'],
    universeId: j['universeId'],
    kind: MediaKind.values.byName(j['kind']),
    title: j['title'],
    releaseDate: j['releaseDate'],
    releaseYear: j['releaseYear'],
    runtimeMinutes: j['runtimeMinutes'],
    director: j['director'],
    blurb: j['blurb'],
    poster: j['poster'],
    showTitle: j['showTitle'],
    seasonNumber: j['seasonNumber'],
    episodes: (j['episodes'] as List? ?? [])
        .map((e) => EpisodeRecord.fromJson(Map<String, dynamic>.from(e)))
        .toList(),
  );
}

class MarathonEntry {
  /// Identifies an occurrence in the list, so repeats can be watched separately.
  final String id;
  final String mediaId;

  /// null means the whole movie/game/season. Non-null is a deliberate episode selection.
  final List<String>? episodeIds;
  MarathonEntry({
    required this.id,
    required this.mediaId,
    List<String>? episodeIds,
  }) : episodeIds = episodeIds == null ? null : List.unmodifiable(episodeIds) {
    if (id.isEmpty || mediaId.isEmpty)
      throw ArgumentError('Entry IDs are required');
    if (episodeIds != null &&
        (episodeIds.isEmpty ||
            episodeIds.toSet().length != episodeIds.length)) {
      throw ArgumentError('Choose at least one episode, without duplicates');
    }
  }
  List<String> units(CatalogMedia media) {
    if (media.id != mediaId)
      throw ArgumentError('Entry points to different media');
    if (media.kind != MediaKind.season) {
      if (episodeIds != null)
        throw ArgumentError('Only seasons support episode selections');
      return [mediaId];
    }
    final all = media.episodes.map((e) => e.id).toList();
    if (episodeIds != null && !episodeIds!.every(all.contains))
      throw ArgumentError('Unknown episode');
    return episodeIds ?? all;
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'mediaId': mediaId,
    'episodeIds': episodeIds,
  };
  factory MarathonEntry.fromJson(Map<String, dynamic> j) => MarathonEntry(
    id: j['id'],
    mediaId: j['mediaId'],
    episodeIds: (j['episodeIds'] as List?)?.cast<String>(),
  );
}

class MarathonDefinition {
  final String id;
  final String title;
  final String? universeId;
  final ViewingOrder order;
  final List<MarathonEntry> entries;

  /// Private media is snapshotted with a custom marathon, so later catalogue edits
  /// cannot change an existing run's episode identities.
  final Map<String, CatalogMedia> media;
  MarathonDefinition({
    required this.id,
    required this.title,
    this.universeId,
    required this.order,
    required List<MarathonEntry> entries,
    required Map<String, CatalogMedia> media,
  }) : entries = List.unmodifiable(entries),
       media = Map.unmodifiable(media) {
    if (entries.map((e) => e.id).toSet().length != entries.length)
      throw ArgumentError('Duplicate list-entry ID');
    for (final e in entries) {
      final item = media[e.mediaId];
      if (item == null) throw ArgumentError('Unknown media: ${e.mediaId}');
      if (e.units(item).isEmpty) throw ArgumentError('A season needs episodes');
    }
  }
  Map<String, dynamic> toJson() => {
    'schemaVersion': 1,
    'title': title,
    'universeId': universeId,
    'order': order.name,
    'entries': entries.map((e) => e.toJson()).toList(),
    'media': media.map((k, v) => MapEntry(k, v.toJson())),
  };
  factory MarathonDefinition.fromJson(String id, Map<String, dynamic> j) =>
      MarathonDefinition(
        id: id,
        title: j['title'],
        universeId: j['universeId'],
        order: ViewingOrder.values.byName(j['order']),
        entries: (j['entries'] as List)
            .map((e) => MarathonEntry.fromJson(Map<String, dynamic>.from(e)))
            .toList(),
        media: (j['media'] as Map).map(
          (k, v) => MapEntry(
            k as String,
            CatalogMedia.fromJson(Map<String, dynamic>.from(v)),
          ),
        ),
      );
}

class RunProgress {
  final Map<String, Set<String>> completed;
  RunProgress([Map<String, Set<String>> values = const {}])
    : completed = Map.unmodifiable(
        values.map((k, v) => MapEntry(k, Set<String>.unmodifiable(v))),
      );
  bool isComplete(MarathonEntry e, CatalogMedia m) {
    final units = e.units(m);
    return units.isNotEmpty &&
        units.every((id) => completed[e.id]?.contains(id) ?? false);
  }

  int count(MarathonEntry e, CatalogMedia m) =>
      e.units(m).where((id) => completed[e.id]?.contains(id) ?? false).length;
  Map<String, dynamic> toJson() =>
      completed.map((k, v) => MapEntry(k, v.toList()));
  factory RunProgress.fromJson(Map<String, dynamic> j) => RunProgress(
    j.map((k, v) => MapEntry(k, (v as List).cast<String>().toSet())),
  );
}
