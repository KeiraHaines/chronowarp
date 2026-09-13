import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/marathon.dart';

/// Read-only artwork lookup. User artwork always wins; games never reach TMDB.
class TmdbPosterService {
  static final instance = TmdbPosterService();
  final http.Client _client;
  final String token;
  final Map<String, Future<String?>> _requests = {};
  Future<Map<String, dynamic>>? _configuration;

  TmdbPosterService({
    http.Client? client,
    this.token = const String.fromEnvironment('TMDB_READ_ACCESS_TOKEN'),
  }) : _client = client ?? http.Client();

  Future<Map<String, dynamic>> _get(
    String path, [
    Map<String, String> query = const {},
  ]) async {
    final response = await _client
        .get(
          Uri.https('api.themoviedb.org', '/3/$path', query),
          headers: {
            'Authorization': 'Bearer $token',
            'Accept': 'application/json',
          },
        )
        .timeout(const Duration(seconds: 10));
    if (response.statusCode != 200) throw StateError('TMDB request failed');
    return jsonDecode(response.body) as Map<String, dynamic>;
  }

  Future<String?> posterFor(CatalogMedia media) async {
    final supplied = media.poster?.trim();
    if (supplied != null && supplied.isNotEmpty) return supplied;
    if (media.kind == MediaKind.game || token.trim().isEmpty) return null;
    final key =
        '${media.kind.name}:${media.title}:${media.showTitle}:${media.releaseYear}:${media.seasonNumber}';
    try {
      return await _requests.putIfAbsent(key, () => _lookup(media));
    } catch (_) {
      // Do not retain network/auth failures: reopening the page can retry.
      _requests.remove(key);
      _configuration = null;
      return null;
    }
  }

  String _normalize(String title) => title
      .toLowerCase()
      .replaceAll('sorcerer', 'philosopher')
      .replaceAll('&', 'and')
      .replaceAll(RegExp(r'[^a-z0-9]'), '');

  Future<String?> _lookup(CatalogMedia media) async {
    final tv = media.kind == MediaKind.season;
    final title = tv
        ? media.showTitle ?? media.title.split(' — Season').first
        : media.title;
    final data = await _get('search/${tv ? 'tv' : 'movie'}', {
      'query': title,
      'include_adult': 'false',
      'language': 'en-AU',
      if (!tv && media.releaseYear != null) 'year': '${media.releaseYear}',
    });
    final matches = (data['results'] as List? ?? [])
        .cast<Map<String, dynamic>>()
        .where((m) {
          final names = [
            m[tv ? 'name' : 'title'],
            m[tv ? 'original_name' : 'original_title'],
          ];
          final sameTitle = names.whereType<String>().any(
            (n) => _normalize(n) == _normalize(title),
          );
          final year = int.tryParse(
            '${m['release_date'] ?? ''}'.split('-').first,
          );
          return sameTitle &&
              (tv || media.releaseYear == null || year == media.releaseYear);
        })
        .toList();
    // Ambiguous matches stay text-only rather than showing the wrong film.
    if (matches.length != 1) return null;
    final match = matches.single;
    String? path = match['poster_path'] as String?;
    if (tv && media.seasonNumber != null) {
      final season = await _get(
        'tv/${match['id']}/season/${media.seasonNumber}',
        {'language': 'en-AU'},
      );
      path = season['poster_path'] as String? ?? path;
    }
    if (path == null || !path.startsWith('/')) return null;
    final config = await (_configuration ??= _get('configuration'));
    final images = config['images'] as Map<String, dynamic>;
    final base = images['secure_base_url'] as String;
    final sizes = (images['poster_sizes'] as List).cast<String>();
    if (!base.startsWith('https://') || sizes.isEmpty) return null;
    final size = sizes.contains('w500') ? 'w500' : sizes.last;
    return '$base$size$path';
  }
}
