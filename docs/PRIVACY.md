# Privacy & Safety

## Principles

* User control first. No central server for social graph.
* Keys stay on device. Export only on explicit request.
* No PII in media URLs, events, or filenames.

## Local storage

* Keys: OS keystore (TBD in future PR; currently stubbed).
* Settings (SharedPreferences):

  * muted pubkeys
  * overlay default hidden
  * custom relays
* Cache/Queue (Hive):

  * thumbnails, recent posts (non-sensitive)
  * queued actions (event JSON fragments)

## Posted to relays

* Event JSON for posts/reactions/replies/zaps as per NIPs.
* Avoid embedding PII in `content` unless user typed it.

## Moderation

* Mute/Block (client side via lists).
* Sensitive blur toggle (planned).
* Report: local log only (no central collector).

## Threat model (MVP)

* Eavesdropping on public relays: content is public by design.
* Upload server sees IP and media. Choose trusted NIP-96 host or self-host.
* Key leakage risk if export flow mishandled: require user confirmation, redact in logs, never auto-export.

## Recommendations

* Consider self-hosting NIP-96 and pinning relays you trust.
* Rotate relays if spammy; maintain mute list.
* For creators: strip EXIF from thumbnails before upload (future enhancement).
