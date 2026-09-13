import 'package:audioplayers/audioplayers.dart';

/// Short original effects; playback failures must never interrupt navigation.
class PortalSound {
  static final _player = AudioPlayer();

  static Future<void> play({bool closing = false}) async {
    try {
      await _player.stop();
      await _player.play(
        AssetSource(
          closing ? 'audio/portal_close.wav' : 'audio/portal_open.wav',
        ),
        volume: 0.45,
        mode: PlayerMode.lowLatency,
      );
    } catch (_) {
      // Audio may be unavailable, for example in widget tests.
    }
  }
}
