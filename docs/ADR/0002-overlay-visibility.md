# ADR 0002: Overlay visibility model

**Decision:** Overlays always visible; long-press toggles cinema mode via opacity+slide, state persisted per device.

**Status:** Accepted.

**Alternatives:** Auto-hide after delay; separate visible state per screen.

**Consequences:** Minimal rebuilds; must preserve accessibility with semantics action when hidden.

