import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/marathon.dart';

class MarathonRepository {
  final FirebaseFirestore db;
  final String uid;
  MarathonRepository({required this.db, required this.uid});
  factory MarathonRepository.current() {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) throw StateError('Sign in to save your marathons');
    return MarathonRepository(db: FirebaseFirestore.instance, uid: user.uid);
  }
  CollectionReference<Map<String, dynamic>> get _marathons =>
      db.collection('users').doc(uid).collection('marathons');
  CollectionReference<Map<String, dynamic>> get _runs =>
      db.collection('users').doc(uid).collection('marathonRuns');
  DocumentReference<Map<String, dynamic>> _universeList(String runId) =>
      db.collection('users').doc(uid).collection('universeLists').doc(runId);
  Stream<DocumentSnapshot<Map<String, dynamic>>> universeList(String runId) =>
      _universeList(runId).snapshots(includeMetadataChanges: true);
  Future<void> saveUniverseList(MarathonDefinition definition) async {
    if (definition.order == ViewingOrder.custom ||
        definition.universeId == null) {
      throw ArgumentError('A universe list needs a universe and viewing order');
    }
    _validateDefinition(definition);
    await _universeList(
      definition.id,
    ).set({...definition.toJson(), 'updatedAt': FieldValue.serverTimestamp()});
  }

  void _validateDefinition(MarathonDefinition definition) {
    if (definition.entries.length > 100 || definition.entries.isEmpty) {
      throw ArgumentError('A list must contain 1–100 entries');
    }
    if (utf8.encode(jsonEncode(definition.toJson())).length > 850000) {
      throw ArgumentError(
        'This list is too large. Split it into smaller lists.',
      );
    }
  }

  Future<Map<String, CatalogMedia>> mediaLibrary() async {
    final snapshots = await Future.wait([
      _marathons.get(),
      db.collection('users').doc(uid).collection('universeLists').get(),
    ]);
    return {
      for (final snapshot in snapshots)
        for (final doc in snapshot.docs)
          ...MarathonDefinition.fromJson(doc.id, doc.data()).media,
    };
  }

  String newId() => _marathons.doc().id;
  Stream<QuerySnapshot<Map<String, dynamic>>> marathons() =>
      _marathons.snapshots(includeMetadataChanges: true);
  Stream<DocumentSnapshot<Map<String, dynamic>>> run(String id) =>
      _runs.doc(id).snapshots(includeMetadataChanges: true);
  Future<void> save(MarathonDefinition definition) async {
    if (definition.entries.length > 100)
      throw ArgumentError('A marathon can contain up to 100 entries');
    if (definition.entries.isEmpty)
      throw ArgumentError('Add at least one item');
    final data = definition.toJson();
    if (utf8.encode(jsonEncode(data)).length > 850000)
      throw ArgumentError(
        'This marathon is too large. Split it into smaller marathons.',
      );
    await _marathons.doc(definition.id).set({
      ...data,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  /// Media photos may be reused in other marathons, so only the private cover
  /// is removed along with this definition and its watched progress.
  Future<void> delete(MarathonDefinition marathon) async {
    if (marathon.order != ViewingOrder.custom) {
      throw ArgumentError('Only custom marathons can be deleted');
    }
    await db.runTransaction((transaction) async {
      final document = _marathons.doc(marathon.id);
      final existing = await transaction.get(document);
      if (!existing.exists) return;
      if (existing.data()?['order'] != 'custom') {
        throw StateError('Only custom marathons can be deleted');
      }
      transaction.delete(document);
      transaction.delete(_runs.doc(marathon.id));
      transaction.delete(
        db
            .collection('users')
            .doc(uid)
            .collection('marathonPhotos')
            .doc('cover-${marathon.id}'),
      );
    });
  }

  Future<void> setCompleted(
    String runId,
    MarathonEntry entry,
    List<String> units,
    bool complete,
  ) => _runs.doc(runId).set({
    'schemaVersion': 1,
    'updatedAt': FieldValue.serverTimestamp(),
    'completed': {
      entry.id: complete
          ? FieldValue.arrayUnion(units)
          : FieldValue.arrayRemove(units),
    },
  }, SetOptions(merge: true));
  static RunProgress progress(
    DocumentSnapshot<Map<String, dynamic>>? snapshot,
  ) => RunProgress.fromJson(
    Map<String, dynamic>.from(snapshot?.data()?['completed'] as Map? ?? {}),
  );
}
