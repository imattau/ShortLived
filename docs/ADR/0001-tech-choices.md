# ADR 0001: Core tech choices

**Decision:** Flutter (mobile), Riverpod (state), video_player+chewie (playback), Hive (cache/queue), dio (HTTP), SharedPreferences (settings), WebSocket (RelayService), LNURL deep links (Lightning).

**Rationale:** Cross-platform performance, simple offline model, mature plugins.

**Alternatives:** React Native; custom media stack.

**Consequences:** One-screen overlay keeps UX focused; add web later if required. Ensure player lifecycle robust and queue ordering preserved.

