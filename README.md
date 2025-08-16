# Nostr Short-Video (One Screen, Overlay UI)

A privacy-first short-video client:
- One screen (full-bleed video) with overlays
- Long-press toggles overlays (cinema mode)
- Vertical feed uses PageView.builder with off-window pages disposed
- Only the current page autoplays; neighbours initialise paused
- At most three video widgets exist at any time
- NIP-96 upload → NIP-94 tags on posts
- Likes (kind 7), comments (kind 1 replies), zaps (9734/9735)
- Offline queue + relay backoff

## Quickstart
```bash
flutter pub get
flutter run
```

Vector icons are loaded from `assets/icons/*.svg.vec`. In dev, if the `.vec` isn't
present yet, `AppIcon` falls back to a Material icon so the UI never shows
empty slots.

### Deterministic widget tests for video
Widget tests run with a `FakeVideoAdapter` via `TestVideoApp`, so no plugin timers are created.
The app itself uses `RealVideoAdapter` (video_player) at runtime via `VideoScope`.
Avoid importing `video_player` in tests — use UI entry points that rely on the adapter.

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

### Overlays
We use a single `OverlayEntry` controlled by `HudState` (ValueNotifiers). Toggling visibility or
muting updates only the overlay subtree; the `PageView` feed is never rebuilt.

Commands
- flutter clean && flutter pub get
- flutter run -d chrome
- flutter test

Acceptance
- Long-press hides/shows overlays smoothly.
- Scrolling feed remains uninterrupted; PageView stays mounted.
- No rebuilds of the feed when toggling HUD (tests pass).
