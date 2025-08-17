# Nostr Short-Video (One Screen, Overlay UI)

A privacy-first short-video client:
- One screen (full-bleed video) with overlays
- Long-press anywhere to hide/show the HUD.
- Desktop/Web: press **H** to toggle.
- A brief hint appears when the HUD is hidden.
- Vertical feed uses PageView.builder with off-window pages disposed
- Only the current page autoplays; neighbours initialise paused
- At most three video widgets exist at any time
- NIP-96 upload → NIP-94 tags on posts
- Likes (kind 7), comments (kind 1 replies), zaps (9734/9735)
- Offline queue + relay backoff
- **Viewer avatar:** bottom-right, always shown when HUD is visible. Tap to open the account menu. Falls back to coloured initials if there’s no picture.
- Hides when HUD is hidden (long-press anywhere to toggle).

## Quickstart
```bash
flutter pub get
flutter run
```

Vector icons are loaded from `assets/icons/*.svg.vec`. In dev, if the `.vec` isn't
present yet, `AppIcon` falls back to a Material icon so the UI never shows
empty slots.

### Caption behaviour
- Overlay caption is clamped to 3 lines with a subtle backdrop and max width (≤ 78% of viewport, capped at 520 px).
- Very long tokens and bech32 refs are wrapped/trimmed for readability.
- Tap **More** to read the full caption in a bottom sheet.

### Sharing
- Share button uses the Web Share API when available; otherwise it copies a deep link to the clipboard.
- Counts are formatted consistently via `utils/count_format.dart`.
- No permissions required; works in PWA too.

### Action stack
- **Action stack is viewport-aware**: on short windows the gaps shrink automatically (min gap 6px), labels use a compact size, and the stack sits closer to centre without overlapping the Create button.
- Buttons use 44 px tap targets with compact spacing and baseline-aligned counts.
- Tooltips appear on web/desktop.

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

Overlay now includes:
- Top-left **Search** pill (opens stub sheet)
- Bottom-left **BottomInfoBar** (avatar, display, npub, caption)
- **Mute** (web-only) under Search
All overlay elements still hide/show with long-press. Opening Search hides the HUD so sheets never overlap Create.

### Controller
`FeedController` owns the current index and muted state. HUD buttons and keyboard shortcuts drive
the controller; `FeedPager` listens and rebuilds only the visible page when mute changes.
Double-tap on a video likes the current item (demo increments count).

### Deep links and share
- Current item is reflected in the URL as `?v=<index>&id=<slug>`.
- Opening the app with `?v=` or `?id=` starts at that item.
- Copy Link action copies a canonical URL that includes both `v` and `id`.

Commands
- flutter clean
- flutter pub get
- flutter run -d chrome
- flutter test

Acceptance
- Navigate to `/?v=1` or `/?id=butterfly` and the second item is initial.
- Scrolling updates the URL without reload.
- Using Copy Link copies a URL that re-opens to the same item.

### Nostr (read-only) adapter
- Enable via build flag:  
  `flutter run -d chrome --dart-define=NOSTR_ENABLED=true`
- Edit default relays in `lib/config/app_config.dart`.
- We subscribe to recent kind-1 notes and try to extract a playable video URL
  from tags `["video" | "media", "<url>"]` or the first `mp4/webm/m3u8` link in content.
- Author display is a short pubkey for now. Proper npub encoding and reaction counts can be added later.

Commands
- flutter clean && flutter pub get
- flutter test
- flutter run -d chrome --dart-define=NOSTR_ENABLED=true

Acceptance
- With flag OFF, the demo feed behaves as before.
- With flag ON and reachable relays, the app loads a list of notes that include video links and displays them as a vertical feed.
- Deep links (`?v=&id=`) still work with the Nostr list.

### Troubleshooting
- **HLS**: Chrome requires hls.js. We include `video_player_web_hls`; make sure it's installed.
- **CORS**: Remote servers must send `Access-Control-Allow-Origin: *` (or your domain). If missing, the player will show “Unsupported or blocked”.
- **Codecs**: Chrome can’t play HEVC/H.265 MP4s. Those will be skipped.
