# Media catalogue and marathons

## Decisions

- Media types: movie, TV season (one entry per season), video game.
- Each universe has separately tracked release-order and chronological runs.
- Universes open directly to the original watching screen in release order.
  The tabs switch between independently tracked orders. Progress syncs through Firebase.
- Custom marathons are private to the signed-in account and primarily contain
  user-entered media. A searchable picker includes all populated universe
  catalogues and media from that user's saved marathons.
- Create opens directly to name and cover, then entries; saved marathons appear
  beside universes in the Home carousel. Draft name, cover and entries survive
  returning to the first step.
- Custom marathons have a confirmed Delete action on their watching page.
  An owner-scoped transaction deletes the definition, progress and cover.
  Shared media photos are preserved because other marathons may reference them.
- Custom marathons and each universe order can be edited: drag to reorder, add
  existing catalogue/private media, add new media, or remove an entry from a draft.
- Universe changes are personal account overrides at
  `users/{uid}/universeLists/{runId}`. The built-in catalogue remains unchanged.
  Home uses the effective personal release list; each watching tab subscribes to
  its own saved list. Empty universes can be populated through the editor.
- Editing keeps the same run ID and existing occurrence IDs. New entries receive
  fresh IDs, and a removed/re-added item starts as a new occurrence. Draft changes
  are applied only when saved. Removed entry progress is retained but ignored.
- Existing watch-party documents and their item numbers are unchanged.

## Identity and order

`CatalogMedia.id` identifies a title/season independently of its display number.
Lion King has explicit stable IDs; the remaining legacy catalogue adapter uses
universe, year and title. Pin explicit IDs before renaming legacy titles.

`MarathonEntry.id` identifies an occurrence in a list. `mediaId` references the
catalogue. `episodeIds == null` means the whole season; a nonempty list means a
specific subset in that order. Entry IDs are not position numbers, so reordering
does not reassign progress. Repeated entries have independent progress.

Example: entry A references season 1 episodes 1–5, entry B references a film,
entry C references season 1 episodes 6–10. Both season entries reuse the same
media record. Completion is stored by run ID, entry ID, and episode ID.

## Metadata

Catalogue records hold title, media type, release date, duration in minutes,
director, blurb and poster. Games interpret duration as average play time.
Seasons additionally hold show title, season number and episode records.
Episode titles are optional; numbers remain available for picking episodes.
Custom episode-title entry is supported during creation.

Existing Lion King movie metadata and ordering are preserved as supplied.
Episode names and available durations now come from official IMDb datasets; see
[IMDb episode sources](imdb-episode-sources.md) for counts, missing values and identity preservation. Missing exact dates, directors and other information remain null
and are shown as not added. A known year is not silently converted to January 1.
The existing chronological list mixes remakes and animated continuity; this is
an author-curated list, not a newly researched canonical chronology.

Pixar previously pointed at Lion King's chronological list. That incorrect
reference is removed; its chronology is unavailable pending real data. Empty
Marvel data remains empty. No franchise facts or games have been invented.

## Firebase

- `users/{uid}/marathons/{id}` stores a versioned custom definition and a snapshot
  of its private media, so later catalogue edits cannot alter saved runs.
- `users/{uid}/marathonRuns/{id}` stores `completed: {entryId: [unitId, ...]}`.
- Curated run IDs include universe, order and template version.
- Updates use Firestore atomic array union/remove operations per entry, avoiding
  whole-run overwrites when two devices change different entries.
- Account UID is captured when the repository is created; one user's progress
  is never served from a shared global in-memory map.
- Firestore snapshot metadata indicates pending sync or cached state. Save is
  not presented as confirmed before the server acknowledges it.
- Custom definitions are capped at 100 entries and 850 KB of serialized JSON.
- Photos are selected only through the phone gallery. No image-link field is shown.
- JPEG compression runs off the UI thread, with a maximum dimension of 1000 px
  and at most 180 KiB per photo. Images are stored as Firestore Blob documents
  under `users/{uid}/marathonPhotos/{photoId}` and sync with the account.
- Cover photo IDs are `cover-{marathonId}`; media snapshots store opaque
  `firestore-photo:{photoId}` references. Photo bytes are not embedded in marathon
  definitions. Covers and media photos use the same renderer and permissions.
- The latest user choice is compressed Firestore photos, not phone-only storage
  or Firebase Storage. No Storage bucket or Storage rules are needed.
- Selected photo previews remain in the draft after failed uploads; saving with
  a selected photo waits for server acknowledgement. The original upload attempt
  failed with Storage HTTP 404 because no bucket had been created.
- Media forms use disappearing hints and a year/calendar picker for dates.
  Custom episode details can include individual names and durations.

The root `firestore.txt` preserves the user's existing rules and adds owner-only
marathon, progress and compressed photo access. The owner published these rules
on 2026-09-08. The live Android integration test then passed: private marathon
and JPEG Blob saved and read back from the server, watched progress marked and
unmarked, then all temporary records deleted.

## Compatibility and deferred work

Legacy solo progress used an in-memory map keyed by list position. It cannot be
reliably assigned to one of two new runs, and was not durable across app restarts.
New runs begin independently; legacy watch-party progress is not migrated or
cleared. Home cards explicitly summarize release-order progress.

Existing solo rating screens remain available for curated universes. Their old
in-memory rating persistence is outside this progress migration. Custom ratings,
watch-party schema migration and catalogue research are
separate follow-ups. Drafts remain in memory until saved; uploaded photo documents can remain if a
draft is abandoned. Cleanup of abandoned draft photos is deferred.

## Validation

`flutter test test` covers stable identity, separate runs, episode groups around
films, repeat occurrences, full-season completion, JSON round-trips, invalid
selections, games, and known-year metadata, plus existing app regression tests.

`flutter test integration_test/marathon_sync_test.dart -d DEVICE_ID` requires an
already signed-in development app. It creates a temporary private definition
and progress record, reads them from the server, tests marking/unmarking, then
removes them. No existing media or watched state is modified.
