# Architecture

This doc explains the app’s structure, data flow, and performance/UX rules.

## Overview

* Flutter mobile app, one route (`HomeFeedPage`), all actions via sheets.
* Services: Relay (WebSocket), Upload (HTTP NIP-96), Lightning (LNURL), Cache (Hive), Settings (SharedPreferences), Queue (Hive).
* State: `FeedController` (index, list, preload ±1), `OverlayVisibilityController` (persisted).

## Module map

```
lib/
  core/…           # constants/DI
  data/…           # models + repos
  services/…       # nostr, upload, lightning, cache, queue, settings
  state/…          # controllers
  ui/…             # one screen + sheets
```

## Data flow (Mermaid)

```mermaid
flowchart TD
  UI[HomeFeedPage + Sheets] -->|actions| State[FeedController]
  State -->|subscribes| Relay[RelayService (WebSocket)]
  UI -->|upload| Upload[UploadService (NIP-96)]
  Upload -->|FileMeta| State
  State -->|publish kind:1/7| Relay
  Relay -->|EVENT frames| Lightning[LightningService listen receipts]
  State --> Cache[Cache/Queue (Hive)]
  Settings[SettingsService] --> UI
```

## Event model

* Post: kind 1 with NIP-94 file tags: `t`, `url`, `dim`, `dur`, `thumb`
* Reaction: kind 7 with `content:"+"` and `["e", <eventId>]`
* Reply: kind 1 with `["e", parent]`, optional `["p", author]`
* Zap: 9734 request (wallet), 9735 receipt (observed)

## Performance budget

* 60 FPS on mid-tier Android
* Only current ±1 “active”
* Overlays toggle via opacity/slide; do not rebuild video layer
* Preload only next/prev thumbnails

## Offline & retry

* ActionQueue persists `publish`, `like`, `reply`
* Replay in order with backoff
* Relay reconnect with exponential backoff

## Testing

* Widget tests: gestures, overlays, sheets pause/resume
* Unit tests: NIP-94 tags, LNURL builder, queue/backoff
* Perf tests: active controllers ≤ 3; PageView not recreated on overlay toggle
