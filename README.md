# Nostr Short-Video (One Screen, Overlay UI)

A privacy-first short-video client:
- One screen (full-bleed video) with overlays
- Long-press toggles overlays (cinema mode)
- NIP-96 upload → NIP-94 tags on posts
- Likes (kind 7), comments (kind 1 replies), zaps (9734/9735)
- Offline queue + relay backoff

## Quickstart
```bash
flutter pub get
flutter run
```

## Configuration

* Default relays: see `lib/core/config/network.dart`
* NIP-96 upload URL: `NetworkConfig.nip96UploadUrl`
* To change overlay default behaviour: open Relays & Settings sheet → toggle “Overlays default to hidden on open”.

## Docs

* docs/ARCHITECTURE.md
* docs/NIPs.md
* docs/PRIVACY.md
* docs/ADR/
