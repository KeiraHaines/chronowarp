import 'package:chronowarp/data/lionking_episodes.dart';
import 'package:chronowarp/data/marathon_catalog.dart';
import 'package:chronowarp/data/universe_configs.dart';
import 'package:chronowarp/models/marathon.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('IMDb import has complete named seasons with traceable identities', () {
    final episodes = lionKingEpisodes.values.expand((e) => e).toList();
    expect(episodes.length, 169);
    expect(episodes.where((e) => e.runtimeMinutes != null).length, 156);
    expect(episodes.map((e) => e.imdbId).toSet().length, 169);
    for (final season in lionKingEpisodes.entries) {
      for (final (index, episode) in season.value.indexed) {
        expect(episode.number, index + 1);
        expect(episode.id, '${season.key}-ep-${index + 1}');
        expect(episode.title, isNotEmpty);
        expect(episode.imdbId, matches(r'^tt\d+$'));
        final restored = EpisodeRecord.fromJson(episode.toJson());
        expect(restored.imdbId, episode.imdbId);
        expect(restored.runtimeMinutes, episode.runtimeMinutes);
      }
    }
  });
  test(
    'new season entries preserve existing progress and missing runtimes',
    () {
      final run = universeMarathon(lionKingConfig, ViewingOrder.release);
      final season = run.media['lion-guard-s2']!;
      final entry = run.entries.firstWhere((e) => e.mediaId == season.id);
      final oldProgress = RunProgress({
        entry.id: {for (var n = 1; n <= 26; n++) 'lion-guard-s2-ep-$n'},
      });
      expect(season.episodes.length, 29);
      expect(oldProgress.count(entry, season), 26);
      expect(oldProgress.isComplete(entry, season), isFalse);
      expect(run.media['lion-guard-s3']!.episodes[4].runtimeMinutes, isNull);
      expect(
        run.media['unbungalievable-s1']!.episodes.first.runtimeMinutes,
        isNull,
      );
      expect(
        run.media['timon-pumbaa-s1']!.episodes.first.detailsLabel,
        '1. Boara Boara/Saskatchewan Catch · 22 min',
      );
    },
  );
}
