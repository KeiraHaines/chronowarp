import 'dart:convert';
import 'package:chronowarp/models/marathon.dart';
import 'package:chronowarp/services/tmdb_poster_service.dart';
import 'package:chronowarp/widgets/media_poster.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

CatalogMedia movie({String? poster, MediaKind kind = MediaKind.movie}) =>
    CatalogMedia(
      id: 'test',
      universeId: 'wizarding-world',
      kind: kind,
      title: "Harry Potter and the Philosopher's Stone",
      releaseYear: 2001,
      poster: poster,
    );
http.Response result(Object value) => http.Response(jsonEncode(value), 200);
void main() {
  test(
    'manual art, games and missing credentials make no API requests',
    () async {
      final client = MockClient((_) => throw StateError('Must not request'));
      final service = TmdbPosterService(client: client, token: 'test');
      expect(
        await service.posterFor(movie(poster: 'assets/manual.png')),
        'assets/manual.png',
      );
      expect(await service.posterFor(movie(kind: MediaKind.game)), isNull);
      expect(
        await TmdbPosterService(client: client).posterFor(movie()),
        isNull,
      );
    },
  );
  test(
    'matches title and year, accepts regional title and reuses requests',
    () async {
      var calls = 0;
      final service = TmdbPosterService(
        token: 'test',
        client: MockClient((r) async {
          calls++;
          expect(r.headers['Authorization'], 'Bearer test');
          if (r.url.path.endsWith('configuration'))
            return result({
              'images': {
                'secure_base_url': 'https://image.tmdb.org/t/p/',
                'poster_sizes': ['w500', 'original'],
              },
            });
          expect(r.url.queryParameters['year'], '2001');
          return result({
            'results': [
              {
                'id': 1,
                'title': "Harry Potter and the Sorcerer's Stone",
                'release_date': '2001-11-16',
                'poster_path': '/stone.jpg',
              },
              {
                'id': 2,
                'title': "Harry Potter and the Philosopher's Stone",
                'release_date': '2020-11-16',
                'poster_path': '/wrong.jpg',
              },
            ],
          });
        }),
      );
      final posters = await Future.wait([
        service.posterFor(movie()),
        service.posterFor(movie()),
      ]);
      expect(
        posters,
        everyElement('https://image.tmdb.org/t/p/w500/stone.jpg'),
      );
      expect(calls, 2);
    },
  );
  test('ambiguous matches never guess a poster', () async {
    final service = TmdbPosterService(
      token: 'test',
      client: MockClient(
        (_) async => result({
          'results': [
            for (var id = 1; id <= 2; id++)
              {
                'id': id,
                'title': movie().title,
                'release_date': '2001-01-01',
                'poster_path': '/a.jpg',
              },
          ],
        }),
      ),
    );
    expect(await service.posterFor(movie()), isNull);
  });
  test('temporary failures can be retried', () async {
    var calls = 0;
    final service = TmdbPosterService(
      token: 'test',
      client: MockClient((_) async {
        calls++;
        return calls == 1 ? http.Response('', 429) : result({'results': []});
      }),
    );
    expect(await service.posterFor(movie()), isNull);
    expect(await service.posterFor(movie()), isNull);
    expect(calls, 2);
  });
  test(
    'season lookup uses show title without confusing season year with debut',
    () async {
      final service = TmdbPosterService(
        token: 'test',
        client: MockClient((r) async {
          if (r.url.path.endsWith('search/tv')) {
            expect(r.url.queryParameters['query'], 'The Lion Guard');
            expect(
              r.url.queryParameters.containsKey('first_air_date_year'),
              isFalse,
            );
            return result({
              'results': [
                {
                  'id': 42,
                  'name': 'The Lion Guard',
                  'poster_path': '/show.jpg',
                },
              ],
            });
          }
          if (r.url.path.endsWith('season/2'))
            return result({'poster_path': '/season2.jpg'});
          return result({
            'images': {
              'secure_base_url': 'https://image.tmdb.org/t/p/',
              'poster_sizes': ['w500'],
            },
          });
        }),
      );
      final media = CatalogMedia(
        id: 's2',
        universeId: 'lion-king',
        kind: MediaKind.season,
        title: 'The Lion Guard — Season 2',
        showTitle: 'The Lion Guard',
        seasonNumber: 2,
        releaseYear: 2017,
      );
      expect(
        await service.posterFor(media),
        'https://image.tmdb.org/t/p/w500/season2.jpg',
      );
    },
  );
  testWidgets('no-token poster collapses without errors', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: MediaPoster(
            media: movie(),
            service: TmdbPosterService(token: ''),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.byType(Image), findsNothing);
    expect(tester.takeException(), isNull);
  });
}
