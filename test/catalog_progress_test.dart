import 'package:chronowarp/data/lionking_data.dart';
import 'package:chronowarp/data/pixar_data.dart';
import 'package:chronowarp/models/media_item.dart';
import 'package:chronowarp/stores/progress_store.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('typed catalog retains movie metadata and season entries', () {
    final first = pixarOrder.first;
    expect(first.type, MediaType.movie);
    expect(first.title, 'The Adventures of Andre & Wally B.');
    expect(first.runtime, '2m');
    expect((first as Movie).director, 'Alvy Ray Smith');
    expect(first.seasons, isNull);
    final season = lionKingReleaseOrder.firstWhere((item) => item.isShow);
    expect(season.seasons, 1);
    expect(season.episodes, 25);
  });

  test('next episode crosses seasons and ends when all are watched', () {
    const seasons = [
      Season(
        seasonNumber: 1,
        episodes: [Episode(episodeNumber: 1, title: 'First')],
      ),
      Season(
        seasonNumber: 2,
        episodes: [Episode(episodeNumber: 1, title: 'Second')],
      ),
    ];
    final store = ProgressStore.instance;
    const universe = 'catalog-progress-test';
    expect(store.nextEpisodeFor(universe, 1, seasons)?.episodeTitle, 'First');
    store.toggleEpisode(universe, 1, 1, 1);
    expect(store.nextEpisodeFor(universe, 1, seasons), (
      seasonNumber: 2,
      episodeNumber: 1,
      episodeTitle: 'Second',
    ));
    store.toggleEpisode(universe, 1, 2, 1);
    expect(store.nextEpisodeFor(universe, 1, seasons), isNull);
    store.toggleEpisode(universe, 1, 1, 1);
    store.toggleEpisode(universe, 1, 2, 1);
  });
}
