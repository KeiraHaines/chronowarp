import 'package:chronowarp/services/marathon_photo_store.dart';
import 'package:image/image.dart' as img;
import 'package:chronowarp/firebase_options.dart';
import 'package:chronowarp/models/marathon.dart';
import 'package:chronowarp/services/marathon_repository.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  testWidgets('private marathon and run progress round-trip through Firebase', (
    tester,
  ) async {
    await Firebase.initializeApp(options: androidFirebaseOptions);
    final user = await FirebaseAuth.instance.authStateChanges().first;
    expect(
      user,
      isNotNull,
      reason: 'The development app must already be signed in',
    );
    final db = FirebaseFirestore.instance;
    final repository = MarathonRepository(db: db, uid: user!.uid);
    final id = repository.newId();
    final media = CatalogMedia(
      id: 'sample-movie',
      universeId: 'private',
      kind: MediaKind.movie,
      title: 'Temporary sync check',
    );
    final entry = MarathonEntry(id: 'sample-entry', mediaId: media.id);
    final definition = MarathonDefinition(
      id: id,
      title: 'Temporary sync check',
      order: ViewingOrder.custom,
      entries: [entry],
      media: {media.id: media},
    );
    final marathonDoc = db
        .collection('users')
        .doc(user.uid)
        .collection('marathons')
        .doc(id);
    final runDoc = db
        .collection('users')
        .doc(user.uid)
        .collection('marathonRuns')
        .doc(id);
    var saved = false,
        runSaved = false,
        photoSaved = false,
        universeSaved = false;
    final universeId = 'test-universe-$id';
    final personalDoc = db
        .collection('users')
        .doc(user.uid)
        .collection('universeLists')
        .doc(universeId);
    final personalRun = db
        .collection('users')
        .doc(user.uid)
        .collection('marathonRuns')
        .doc(universeId);
    final photos = MarathonPhotoStore(repository);
    final photoId = 'cover-$id';
    final photoRef = MarathonPhotoStore.reference(photoId);
    try {
      await repository.save(definition).timeout(const Duration(seconds: 20));
      saved = true;
      final photoBytes = compressMarathonPhoto(
        img.encodePng(img.Image(width: 16, height: 16)),
      );
      await photos.save(photoId, photoBytes);
      photoSaved = true;
      final storedPhoto = await db
          .collection('users')
          .doc(user.uid)
          .collection('marathonPhotos')
          .doc(photoId)
          .get(const GetOptions(source: Source.server));
      expect((storedPhoto.data()!['bytes'] as Blob).bytes, photoBytes);
      expect(await photos.read(photoRef), photoBytes);
      final stored = await marathonDoc.get(
        const GetOptions(source: Source.server),
      );
      expect(
        MarathonDefinition.fromJson(id, stored.data()!).entries.single.mediaId,
        media.id,
      );
      await repository
          .setCompleted(id, entry, [media.id], true)
          .timeout(const Duration(seconds: 20));
      runSaved = true;
      var run = await runDoc.get(const GetOptions(source: Source.server));
      expect(MarathonRepository.progress(run).isComplete(entry, media), isTrue);
      await repository.setCompleted(id, entry, [media.id], false);
      run = await runDoc.get(const GetOptions(source: Source.server));
      expect(
        MarathonRepository.progress(run).isComplete(entry, media),
        isFalse,
      );
      final secondEntry = MarathonEntry(id: 'repeat-entry', mediaId: media.id);
      final personal = MarathonDefinition(
        id: universeId,
        title: 'Temporary universe edit',
        universeId: 'test-universe',
        order: ViewingOrder.release,
        entries: [entry, secondEntry],
        media: {media.id: media},
      );
      await repository.saveUniverseList(personal);
      universeSaved = true;
      await repository.setCompleted(universeId, entry, [media.id], true);
      final edited = MarathonDefinition(
        id: universeId,
        title: personal.title,
        universeId: personal.universeId,
        order: personal.order,
        entries: [secondEntry, entry],
        media: personal.media,
      );
      await repository.saveUniverseList(edited);
      final storedList = MarathonDefinition.fromJson(
        universeId,
        (await personalDoc.get(
          const GetOptions(source: Source.server),
        )).data()!,
      );
      expect(storedList.entries.map((e) => e.id), [secondEntry.id, entry.id]);
      final personalProgress = MarathonRepository.progress(
        await personalRun.get(const GetOptions(source: Source.server)),
      );
      expect(
        personalProgress.isComplete(storedList.entries.last, media),
        isTrue,
      );
      expect(
        personalProgress.isComplete(storedList.entries.first, media),
        isFalse,
      );
      await repository.delete(definition);
      expect(
        (await marathonDoc.get(const GetOptions(source: Source.server))).exists,
        isFalse,
      );
      expect(
        (await runDoc.get(const GetOptions(source: Source.server))).exists,
        isFalse,
      );
      expect(await photos.read(photoRef), isNull);
    } finally {
      if (universeSaved) {
        await personalRun.delete();
        await personalDoc.delete();
      }
      if (photoSaved) await photos.remove(photoRef);
      if (runSaved) await runDoc.delete();
      if (saved) await marathonDoc.delete();
    }
  });
}
