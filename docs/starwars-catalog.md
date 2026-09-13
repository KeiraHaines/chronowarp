# Star Wars catalogue

Imported from all 72 numbered steps in `universe/starwars.txt`, preserving the source file unchanged. Metadata retrieved from TMDB on 9 September 2026; per-title sources are in `starwars-catalog-sources.json`.

The app contains 63 catalogue records: 21 films/specials/announced film projects, one bonus audio-comic placeholder, and 41 seasons/short collections containing 542 episode units. Chronology expands the source into 102 segments. Chapter 22 of the 2003 Clone Wars appears twice because the source pauses it and resumes it later; it retains one episode identity. The profile's unique watched count therefore does not count it twice.

Release order uses original US public movie release dates (excluding premieres), falling back to TMDB's default when unavailable. Seasons and short collections are grouped by their earliest included episode date, matching the Marvel catalogue's season-based release order. This does not interleave episodes of concurrently airing shows. Date ties use title ordering. Unknown dates sort after dated titles without inventing a year; these show TBA where a year is required.

Starfighter uses the official announced US date, [28 May 2027](https://www.starwars.com/news/star-wars-starfighter-ryan-gosling). Dawn of the Jedi, the untitled Dave Filoni project, and New Jedi Order remain undated placeholders in the positions requested by the source; their inclusion does not assert a confirmed production schedule. [Lucasfilm's original announcement](https://www.starwars.com/news/swce-2023-new-star-wars-films) identifies those projects.

## Numbering and source corrections

- The Bad Batch source says Season 1 Episodes 2–18, but that season has 16 episodes. Import uses 2–16 and retains the correction as a viewing note.
- The Mandalorian source mixes season and overall chapter numbering. Its first Season 2 block is Episodes 1–4 (Chapters 9–12); the later block is Episodes 5–8 (Chapters 13–16). [Official Chapter 13 guide](https://www.starwars.com/series/the-mandalorian/chapter-13-guide).
- Rebels: include the four introductory shorts; place Spark of Rebellion at the start of Season 1 as one double-length episode to match the source's 14-episode layout. Split Siege of Lothal and Twilight of the Apprentice into two parts for its 22-entry Season 2, and Steps Into Shadow into two parts for its 22-entry Season 3. Combine Family Reunion – and Farewell for the source's 15-entry Season 4. Metadata dates are retained; runtimes for split halves are unknown rather than guessed.
- Resistance: split The Recruit and The Escape into two parts to match the source's 21- and 19-entry seasons. [Official two-part premiere guide](https://www.starwars.com/news/the-recruit-episode-guide-star-wars-resistance).
- The 2003 Clone Wars uses TMDB seasons (Chapters 1–10, 11–20, 21–25); chronological episode selection preserves the source's nonnumeric sequence. The chapter-22 pause/resume instructions are displayed on the relevant blocks. Progress remains at episode granularity, not timestamps.
- Crystal Crisis on Utapau includes only the four requested story reels from TMDB's specials, not the unrelated later specials.
- Darth Maul: Son of Dathomir (Audio Comic) is retained as a clearly named, single-completion bonus item. The source does not identify an audio adaptation, so no release date or runtime is fabricated. The app currently groups standalone bonus items under its movie type; it has no dedicated audio-comic media type.
- Unqualified series entries include all non-special seasons with episodes and a first-air date on or before the metadata retrieval date. No unrequested future seasons are added.

Viewing notes survive catalogue snapshot serialization. Existing built-in progress IDs for other universes are unchanged.

The existing 100-entry full-list editing limit also applies here: Star Wars release order can be edited, but saving the complete 102-segment chronological list requires raising the client and deployed rules limits. Ordinary viewing/progress tracking does not use that limit.
