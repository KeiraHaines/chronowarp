# TMDB posters

Movies and TV seasons without supplied artwork use TMDB. Games only use supplied
artwork. Existing assets, HTTPS URLs, and private photo references take priority.
The next-up poster appears in universe and custom marathon lists. Missing matches,
missing credentials, and API failures leave the entry text-only.

## Local setup

Create a TMDB account and request API access at https://www.themoviedb.org/settings/api.
Save the API Read Access Token in `.env.tmdb.json` at the repository root:

```json
{"TMDB_READ_ACCESS_TOKEN":"your token"}
```

This file is ignored by Git. From the repository root:

```sh
flutter run --dart-define-from-file=.env.tmdb.json -d DEVICE_ID
flutter build apk --debug --target-platform android-arm64 --dart-define-from-file=.env.tmdb.json
```

Pass the file for every build that needs live posters. Builds without it remain
usable with supplied artwork. Do not commit or log the token. A build-time token
is included in the app binary; move API calls behind a backend before public
 distribution if the credential must remain private.

## Matching and display

Search uses the title and movie release year, then requires one matching result.
Punctuation and the Philosopher/Sorcerer regional title are normalized. TV searches
use the show title and fetch the requested season's artwork, falling back to the
series poster if the season has none. Ambiguous matches remain text-only.
TMDB configuration supplies the image host and sizes; w500 is preferred.
Lookups are shared and cached for the current app session. Failed requests are
retryable when the poster widget is reopened. No watch progress or ratings are
sent to TMDB and no catalogue metadata is overwritten.

## Attribution

Profile → About & credits includes the approved TMDB logo and required notice.
Logo source: https://www.themoviedb.org/about/logos-attribution
API documentation: https://developer.themoviedb.org/docs/getting-started
Non-commercial use requires attribution; commercial use requires arranging a
licence with TMDB: https://developer.themoviedb.org/docs/faq
