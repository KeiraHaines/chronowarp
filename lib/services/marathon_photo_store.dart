import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:image/image.dart' as img;
import 'marathon_repository.dart';

/// Runs off the UI thread. Photo documents remain well below Firestore's 1 MiB limit.
Uint8List compressMarathonPhoto(Uint8List bytes) {
  img.Image? decoded;
  try {
    decoded = img.decodeImage(bytes);
  } catch (_) {
    throw const FormatException('Choose a valid JPEG, PNG or WebP photo.');
  }
  if (decoded == null)
    throw const FormatException('Choose a JPEG, PNG or WebP photo.');
  final oriented = img.bakeOrientation(decoded);
  for (final size in [1000, 800, 600, 400]) {
    final resized = oriented.width <= size && oriented.height <= size
        ? oriented
        : img.copyResize(
            oriented,
            width: oriented.width >= oriented.height ? size : null,
            height: oriented.height > oriented.width ? size : null,
          );
    for (final quality in [85, 70, 55]) {
      final encoded = img.encodeJpg(resized, quality: quality);
      if (encoded.length <= MarathonPhotoStore.maxBytes) return encoded;
    }
  }
  throw const FormatException(
    'That photo is too detailed. Please choose a smaller image.',
  );
}

class MarathonPhotoStore {
  static const prefix = 'firestore-photo:';
  static const maxBytes = 180 * 1024;
  static String reference(String id) => '$prefix$id';
  static bool isPhoto(String ref) => ref.startsWith(prefix);
  final MarathonRepository repository;
  MarathonPhotoStore(this.repository);
  factory MarathonPhotoStore.current() =>
      MarathonPhotoStore(MarathonRepository.current());
  DocumentReference<Map<String, dynamic>> _doc(String ref) {
    if (!isPhoto(ref)) throw const FormatException('Invalid photo reference');
    final id = ref.substring(prefix.length);
    if (!RegExp(r'^[a-zA-Z0-9_-]+$').hasMatch(id))
      throw const FormatException('Invalid photo ID');
    return repository.db
        .collection('users')
        .doc(repository.uid)
        .collection('marathonPhotos')
        .doc(id);
  }

  Future<Uint8List> compress(Uint8List bytes) =>
      compute(compressMarathonPhoto, bytes);
  Future<String> save(String id, Uint8List jpeg) async {
    if (jpeg.length > maxBytes)
      throw const FormatException('Photo is too large.');
    final ref = reference(id);
    await _doc(ref)
        .set({
          'schemaVersion': 1,
          'contentType': 'image/jpeg',
          'bytes': Blob(jpeg),
          'updatedAt': FieldValue.serverTimestamp(),
        })
        .timeout(const Duration(seconds: 20));
    return ref;
  }

  Future<Uint8List?> read(String ref) async {
    final data = (await _doc(ref).get()).data();
    return (data?['bytes'] as Blob?)?.bytes;
  }

  Future<void> remove(String ref) =>
      _doc(ref).delete().timeout(const Duration(seconds: 20));
}
