# Lion King episode metadata

Imported on 2026-09-08 from IMDb's official downloadable datasets:

- https://datasets.imdbws.com/title.episode.tsv.gz (parent title, season, episode number)
- https://datasets.imdbws.com/title.basics.tsv.gz (primary title and runtimeMinutes)
- Field definitions: https://developer.imdb.com/non-commercial-datasets/

The downloaded archives remain outside the repository in /tmp/chronowarp-imdb.
Only the relevant episode facts are bundled in lib/data/lionking_episodes.dart.
Each record retains its IMDb ID for source verification.

| Series | IMDb ID | Season episode counts |
| --- | --- | --- |
| Timon & Pumbaa | tt0112197 | 25, 21, 39 |
| The Lion Guard | tt3793630 | 26, 29, 19 |
| Lion Guard: It's Unbungalievable | tt6472898 | 10 |

169 named episodes; 156 have an IMDb runtime. All ten Unbungalievable shorts
and Lion Guard S3 E5, E8 and E9 lack a runtime in this dataset. These remain
null and display Duration not added yet. No generic series runtime is substituted.
IMDb runtime values are preserved as supplied, including unusually long values.

The Lion Guard's unlabelled S1 E0 record (tt13878032, Episode #1.0) is excluded.
The existing Return of the Roar film entry remains separate and unchanged.
Lion Guard S2 now contains 29 episodes instead of the original 26 placeholders.
Its existing E1–E26 IDs are unchanged and E27–E29 are appended. A previously
complete season may therefore show three additional unwatched episodes.
All existing run IDs and other episode IDs remain unchanged. Legacy watch-party
lists are not migrated by this import; custom saved definitions retain snapshots.

Timon & Pumbaa uses IMDb's combined broadcast episodes; slash-separated segment
titles remain together under their shared episode duration.
