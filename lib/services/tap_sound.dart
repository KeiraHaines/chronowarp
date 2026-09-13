import 'package:audioplayers/audioplayers.dart';

class TapSound {
  static final _player = AudioPlayer();
  static Future<void> play({bool rating = false}) async {
    try {
      await _player.stop();
      await _player.play(
        AssetSource(rating ? 'audio/tap.wav' : 'audio/button_tap.wav'),
        volume: 0.3,
        mode: PlayerMode.lowLatency,
      );
    } catch (_) {
      // Controls remain usable if audio is unavailable.
    }
  }
}
