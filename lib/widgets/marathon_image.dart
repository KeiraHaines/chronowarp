import 'dart:typed_data';
import 'package:flutter/material.dart';
import '../services/marathon_photo_store.dart';

/// Shared rendering for bundled catalogue art and account-synced private photos.
class MarathonImage extends StatefulWidget {
  final String source;
  final BoxFit fit;
  final Widget? placeholder;
  const MarathonImage({
    super.key,
    required this.source,
    this.fit = BoxFit.cover,
    this.placeholder,
  });
  @override
  State<MarathonImage> createState() => _MarathonImageState();
}

class _MarathonImageState extends State<MarathonImage> {
  Future<Uint8List?>? _photo;
  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void didUpdateWidget(MarathonImage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.source != widget.source) _load();
  }

  void _load() {
    _photo = MarathonPhotoStore.isPhoto(widget.source) ? _readPhoto() : null;
  }

  Future<Uint8List?> _readPhoto() =>
      MarathonPhotoStore.current().read(widget.source);
  Widget get placeholder =>
      widget.placeholder ??
      const Center(
        child: Icon(Icons.photo_outlined, size: 64, color: Colors.white54),
      );
  @override
  Widget build(BuildContext context) {
    if (_photo != null)
      return FutureBuilder<Uint8List?>(
        future: _photo,
        builder: (context, snapshot) {
          if (snapshot.data == null) return placeholder;
          return Image.memory(
            snapshot.data!,
            fit: widget.fit,
            errorBuilder: (_, error, stack) => placeholder,
          );
        },
      );
    if (widget.source.startsWith('assets/'))
      return Image.asset(
        widget.source,
        fit: widget.fit,
        errorBuilder: (_, error, stack) => placeholder,
      );
    if (Uri.tryParse(widget.source)?.scheme == 'https')
      return Image.network(
        widget.source,
        fit: widget.fit,
        errorBuilder: (_, error, stack) => placeholder,
      );
    return placeholder;
  }
}
