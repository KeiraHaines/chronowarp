import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../data/marathon_catalog.dart';
import '../models/media_item.dart';

class RatingStore {
  static SharedPreferences? _prefs;
  static String? _uid;
  static Future<void> initialize() async {
    _prefs = await SharedPreferences.getInstance();
  }

  static String _key(String uid, String id) => 'ratings.v1.$uid.$id';

  static void activate(String? uid) {
    if (_uid == uid) return;
    _uid = uid;
    for (final config in availableUniverses) {
      for (final item in [
        ...config.releaseItems,
        ...config.chronologicalItems,
      ]) {
        item.categoryRating = null;
        if (uid == null) continue;
        final id = mediaIdFor(universeIdFor(config.title), item);
        final raw = _prefs?.getString(_key(uid, id));
        if (raw == null) continue;
        try {
          final data = jsonDecode(raw) as Map<String, dynamic>;
          double? score(String key) {
            final value = data[key];
            return value is num && value.isFinite && value >= 1 && value <= 10
                ? value.toDouble()
                : null;
          }

          item.categoryRating = CategoryRating(
            story: score('story'),
            acting: score('acting'),
            action: score('action'),
            visuals: score('visuals'),
            sound: score('sound'),
          );
        } catch (_) {
          // Ignore an invalid record without hiding the rest of the catalogue.
        }
      }
    }
  }

  static CategoryRating? read(String id) {
    if (_uid == null) return null;
    final raw = _prefs?.getString(_key(_uid!, id));
    if (raw == null) return null;
    try {
      final data = jsonDecode(raw) as Map<String, dynamic>;
      double? score(String key) {
        final value = data[key];
        return value is num && value.isFinite && value >= 1 && value <= 10
            ? value.toDouble()
            : null;
      }

      return CategoryRating(
        story: score('story'),
        acting: score('acting'),
        action: score('action'),
        visuals: score('visuals'),
        sound: score('sound'),
      );
    } catch (_) {
      return null;
    }
  }

  static Future<void> save(String id, CategoryRating rating) async {
    final uid = _uid;
    if (uid == null || _prefs == null)
      throw StateError('Sign in to save ratings');
    final saved = await _prefs!.setString(
      _key(uid, id),
      jsonEncode({
        'story': rating.story,
        'acting': rating.acting,
        'action': rating.action,
        'visuals': rating.visuals,
        'sound': rating.sound,
      }),
    );
    if (!saved) throw StateError('Could not save rating');
    if (_uid != uid) return;
    for (final config in availableUniverses) {
      for (final item in [
        ...config.releaseItems,
        ...config.chronologicalItems,
      ]) {
        if (mediaIdFor(universeIdFor(config.title), item) == id)
          item.categoryRating = rating;
      }
    }
  }
}
