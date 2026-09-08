import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FirestoreService {
  FirestoreService._internal();
  static final FirestoreService instance = FirestoreService._internal();

  final _db = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;

  String get _uid => _auth.currentUser!.uid;

  // ── User ────────────────────────────────────────────────────────────────────

  Future<void> ensureUserDoc(String displayName) async {
    final ref = _db.collection('users').doc(_uid);
    final snap = await ref.get();
    if (!snap.exists) {
      await ref.set({
        'displayName': displayName,
        'displayNameLower': displayName.toLowerCase(), // ← add this
        'email': _auth.currentUser!.email,
        'friendIds': [],
        'pendingPartyInvites': [],
      });
    }
  }

  Stream<DocumentSnapshot> userStream(String uid) =>
      _db.collection('users').doc(uid).snapshots();

  Future<List<Map<String, dynamic>>> searchUsers(String query) async {
    final q = query.toLowerCase().trim();
    print('Searching for: "$q"');

    try {
      final snap = await _db
          .collection('users')
          .where('displayNameLower', isGreaterThanOrEqualTo: q)
          .where('displayNameLower', isLessThanOrEqualTo: '$q\uf8ff')
          .limit(10)
          .get();

      print('Found ${snap.docs.length} results');
      for (final doc in snap.docs) {
        print('  - ${doc.data()}');
      }

      return snap.docs
          .where((d) => d.id != _uid)
          .map((d) => {'uid': d.id, ...d.data()})
          .toList();
    } catch (e) {
      print('Search error: $e');
      return [];
    }
  }

  // ── Friend Requests ─────────────────────────────────────────────────────────

  Future<void> sendFriendRequest(String toUid) async {
    await _db.collection('friendRequests').add({
      'fromUid': _uid,
      'toUid': toUid,
      'status': 'pending',
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  Stream<QuerySnapshot> incomingRequestsStream() => _db
      .collection('friendRequests')
      .where('toUid', isEqualTo: _uid)
      .where('status', isEqualTo: 'pending')
      .snapshots();

  Stream<QuerySnapshot> outgoingRequestsStream() => _db
      .collection('friendRequests')
      .where('fromUid', isEqualTo: _uid)
      .where('status', isEqualTo: 'pending')
      .snapshots();

  Future<void> respondToRequest(String requestId, bool accept) async {
    print('Responding to request: $requestId, accept: $accept');
    try {
      final batch = _db.batch();
      final reqRef = _db.collection('friendRequests').doc(requestId);

      if (accept) {
        final snap = await reqRef.get();
        final fromUid = snap['fromUid'] as String;
        print('Adding friend: $fromUid');
        batch.update(reqRef, {'status': 'accepted'});
        batch.update(_db.collection('users').doc(_uid), {
          'friendIds': FieldValue.arrayUnion([fromUid]),
        });
        batch.update(_db.collection('users').doc(fromUid), {
          'friendIds': FieldValue.arrayUnion([_uid]),
        });
      } else {
        batch.update(reqRef, {'status': 'declined'});
      }
      await batch.commit();
      print('Done');
    } catch (e) {
      print('respondToRequest error: $e');
    }
  }

  Stream<DocumentSnapshot> myFriendsStream() =>
      _db.collection('users').doc(_uid).snapshots();

  Future<Map<String, dynamic>?> getUser(String uid) async {
    final snap = await _db.collection('users').doc(uid).get();
    if (!snap.exists) return null;
    return {'uid': snap.id, ...snap.data()!};
  }

  // ── Watch Parties ───────────────────────────────────────────────────────────

  Future<String> createWatchParty({
    required String universeKey,
    required String title,
    required List<String> invitedUids,
  }) async {
    final ref = await _db.collection('watchParties').add({
      'title': title,
      'universeKey': universeKey,
      'leaderUid': _uid,
      'memberIds': [_uid],
      'invitedIds': invitedUids,
      'watchedNumbers': [],
      'createdAt': FieldValue.serverTimestamp(),
    });

    // Write pending invite onto each invited user doc
    for (final uid in invitedUids) {
      await _db.collection('users').doc(uid).update({
        'pendingPartyInvites': FieldValue.arrayUnion([ref.id]),
      });
    }
    return ref.id;
  }

  Future<void> acceptPartyInvite(String partyId) async {
    final batch = _db.batch();
    batch.update(_db.collection('watchParties').doc(partyId), {
      'memberIds': FieldValue.arrayUnion([_uid]),
      'invitedIds': FieldValue.arrayRemove([_uid]),
    });
    batch.update(_db.collection('users').doc(_uid), {
      'pendingPartyInvites': FieldValue.arrayRemove([partyId]),
    });
    await batch.commit();
  }

  Future<void> declinePartyInvite(String partyId) async {
    await _db.collection('users').doc(_uid).update({
      'pendingPartyInvites': FieldValue.arrayRemove([partyId]),
    });
  }

  Stream<QuerySnapshot> myPartiesStream() {
    print('Fetching parties for: $_uid');
    return _db
        .collection('watchParties')
        .where('memberIds', arrayContains: _uid)
        .orderBy('createdAt', descending: true)
        .snapshots();
  }

  Stream<DocumentSnapshot> partyStream(String partyId) =>
      _db.collection('watchParties').doc(partyId).snapshots();

  /// Leader only — toggle watched for an item number
  Future<void> toggleWatched(
    String partyId,
    int number,
    bool currentlyWatched,
  ) async {
    await _db.collection('watchParties').doc(partyId).update({
      'watchedNumbers': currentlyWatched
          ? FieldValue.arrayRemove([number])
          : FieldValue.arrayUnion([number]),
    });
  }

  // ── Party Ratings ───────────────────────────────────────────────────────────

  Future<void> savePartyRating({
    required String partyId,
    required int itemNumber,
    required double? story,
    required double? acting,
    required double? action,
    required double? visuals,
    required double? sound,
  }) async {
    await _db
        .collection('watchParties')
        .doc(partyId)
        .collection('ratings')
        .doc('${_uid}_$itemNumber')
        .set({
          'uid': _uid,
          'itemNumber': itemNumber,
          'story': story,
          'acting': acting,
          'action': action,
          'visuals': visuals,
          'sound': sound,
          'updatedAt': FieldValue.serverTimestamp(),
        });
  }

  Future<void> leaveParty(String partyId) async {
    await _db.collection('watchParties').doc(partyId).update({
      'memberIds': FieldValue.arrayRemove([_uid]),
    });
  }

  Stream<QuerySnapshot> partyRatingsStream(String partyId) => _db
      .collection('watchParties')
      .doc(partyId)
      .collection('ratings')
      .snapshots();
}
