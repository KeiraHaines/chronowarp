import 'dart:async';
import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../services/marathon_photo_store.dart';

class MarathonPhotoField extends StatefulWidget {
  final String Function() objectId;
  final String label;
  final ValueChanged<String?> onChanged;
  final ValueChanged<bool> onReady;
  const MarathonPhotoField({
    super.key,
    required this.objectId,
    required this.label,
    required this.onChanged,
    required this.onReady,
  });
  @override
  State<MarathonPhotoField> createState() => _MarathonPhotoFieldState();
}

class _MarathonPhotoFieldState extends State<MarathonPhotoField> {
  late final _store = MarathonPhotoStore.current();
  Uint8List? _bytes;
  bool _busy = false;
  bool _saved = true;
  String? _error;
  Future<void> _pick() async {
    setState(() {
      _busy = true;
      _error = null;
    });
    widget.onReady(false);
    try {
      final image = await ImagePicker().pickImage(
        source: ImageSource.gallery,
        maxWidth: 1600,
        maxHeight: 1600,
        imageQuality: 85,
      );
      if (image == null || !mounted) return;
      final bytes = await image.readAsBytes();
      if (bytes.length > 15 * 1024 * 1024)
        throw const FormatException('Choose a smaller photo (under 15 MB).');
      final compressed = await _store.compress(bytes);
      if (!mounted) return;
      setState(() {
        _bytes = compressed;
        _saved = false;
      });
      widget.onChanged(null);
      await _savePhoto();
    } on FormatException catch (e) {
      if (mounted) setState(() => _error = e.message);
    } catch (_) {
      if (mounted)
        setState(
          () => _error = 'Could not open that photo. Please try another.',
        );
    } finally {
      if (mounted) {
        setState(() => _busy = false);
        widget.onReady(_saved);
      }
    }
  }

  Future<void> _savePhoto() async {
    try {
      final ref = await _store.save(widget.objectId(), _bytes!);
      if (mounted) {
        _saved = true;
        widget.onChanged(ref);
      }
    } on FirebaseException catch (e) {
      if (mounted)
        _error = e.code == 'permission-denied'
            ? 'Photo access is not enabled yet. Your photo is ready; retry once account access is available.'
            : 'Could not save your photo. Check your connection and retry.';
    } on TimeoutException {
      if (mounted)
        _error =
            'Photo sync timed out. Your photo is still here; retry when connected.';
    } catch (_) {
      if (mounted) _error = 'Could not save your photo. Please retry.';
    }
  }

  Future<void> _retry() async {
    setState(() {
      _busy = true;
      _error = null;
    });
    widget.onReady(false);
    await _savePhoto();
    if (mounted) {
      setState(() => _busy = false);
      widget.onReady(_saved);
    }
  }

  Future<void> _remove() async {
    setState(() => _busy = true);
    widget.onReady(false);
    try {
      await _store.remove(MarathonPhotoStore.reference(widget.objectId()));
      if (!mounted) return;
      setState(() {
        _bytes = null;
        _error = null;
        _saved = true;
      });
      widget.onChanged(null);
    } catch (_) {
      if (mounted)
        setState(
          () => _error =
              'Could not remove the photo. Please retry when connected.',
        );
    } finally {
      if (mounted) {
        setState(() => _busy = false);
        widget.onReady(_saved);
      }
    }
  }

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      if (_bytes != null)
        ClipRRect(
          borderRadius: BorderRadius.circular(18),
          child: Image.memory(_bytes!, height: 190, fit: BoxFit.cover),
        ),
      OutlinedButton.icon(
        onPressed: _busy ? null : _pick,
        icon: const Icon(Icons.photo_library_outlined),
        label: Text(
          _busy
              ? 'Saving photo…'
              : _bytes == null
              ? widget.label
              : 'Choose another photo',
        ),
      ),
      if (_error != null) ...[
        Text(_error!, style: const TextStyle(color: Colors.orangeAccent)),
        if (_bytes != null && !_saved)
          TextButton(
            onPressed: _busy ? null : _retry,
            child: const Text('Retry photo save'),
          ),
      ],
      if (_bytes != null)
        TextButton(
          onPressed: _busy ? null : _remove,
          child: const Text('Remove photo'),
        ),
    ],
  );
}
