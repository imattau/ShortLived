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

## Flutter Web white screen (debug)
If you see a blank page on `flutter run -d chrome`:

1. This repo unregisters service workers in debug web automatically.
2. `web/index.html` contains a localhost bootstrap via `flutter.js` to start the engine when injection fails.
3. `web/install_prompt.js` is a no-throw stub and cannot block startup.

If the page is still blank, open DevTools → Console and copy the first error. Common issues:
- Missing vector icon assets (`assets/icons/*.svg` not compiled to `.svg.vec`).
- A custom script added outside of this PR that throws early.
