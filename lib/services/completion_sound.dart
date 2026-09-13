import 'package:audioplayers/audioplayers.dart';

class CompletionSound {
  static final _player = AudioPlayer();
  static Future<void> play() async {
    try {
      await _player.stop();
      await _player.play(
        AssetSource('audio/movie_complete.wav'),
        volume: 0.45,
        mode: PlayerMode.lowLatency,
      );
    } catch (_) {
      // Sound availability must not affect saved progress.
    }
  }
}
