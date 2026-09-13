# Marvel catalogue

Imported on 2026-09-09 from `universe/MarveL_chronological.txt` without modifying
that reference file. The user's 120 chronological steps expand to 131 entries
because a single source step can contain several seasons or noncontiguous episode
groups. All source steps remain in their original sequence, including multiverse
placements and upcoming titles. This is the user's curated chronology, not an
assertion that every placement is official Marvel canon.

The catalogue contains 48 films/shorts/specials and 54 seasons (551 episodes).
Chronological selections collectively cover every film and episode exactly once.
Release order has 102 entries: each film once and each season once, ordered by
first public release / first episode date. Episodes remain in their season rather
than interleaving weekly broadcasts with films.

Metadata and artwork were retrieved using the authenticated TMDB API. Films use
the earliest US public release in TMDB (limited, theatrical, digital, physical or
TV), excluding premiere-only dates. If a US public date is absent, TMDB's default
release date is used. Seasons use TMDB's season first-air date. The Consultant
correctly uses its 2011 physical release rather than its 2022 streaming re-release.
Scheduled future releases are identified in their descriptions; runtimes for
unreleased films are left unset. These dates are a snapshot and may change.

`marvel-catalog-sources.json` records the original file hash, TMDB IDs, source URLs,
and date basis for every record. The generated Dart data contains the metadata,
release sequence, and chronological episode selections. Stable IDs derive from
TMDB film/series IDs and season/episode numbers. Chronological occurrence IDs also
retain source step numbers so progress is independent of display position.

No Firebase catalogue upload is required: the existing app bundles its curated
catalogues; account-specific progress continues to sync through Firebase.
