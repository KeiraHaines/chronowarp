import 'package:flutter/material.dart';
import '../models/marathon.dart';
import '../services/tmdb_poster_service.dart';
import 'marathon_image.dart';

/// Collapses when no poster is available, including offline and missing-token cases.
class MediaPoster extends StatefulWidget {
  final CatalogMedia media;
  final TmdbPosterService? service;
  const MediaPoster({super.key, required this.media, this.service});
  @override
  State<MediaPoster> createState() => _MediaPosterState();
}

class _MediaPosterState extends State<MediaPoster> {
  late Future<String?> _poster;
  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void didUpdateWidget(MediaPoster oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.media != widget.media ||
        oldWidget.service != widget.service) {
      _load();
    }
  }

  void _load() {
    _poster = (widget.service ?? TmdbPosterService.instance).posterFor(
      widget.media,
    );
  }

  @override
  Widget build(BuildContext context) => FutureBuilder<String?>(
    future: _poster,
    builder: (context, snapshot) {
      final source = snapshot.data;
      if (source == null || snapshot.connectionState != ConnectionState.done) {
        return const SizedBox.shrink();
      }
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Center(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: SizedBox(
              height: 280,
              width: 187,
              child: MarathonImage(source: source, fit: BoxFit.contain),
            ),
          ),
        ),
      );
    },
  );
}
