# ADR 0003: Offline action queue

**Decision:** Persist actions (publish/like/reply) in Hive, replay on reconnect in order with exponential backoff.

**Status:** Accepted.

**Alternatives:** Drop actions; server-side queue.

**Consequences:** Must ensure idempotency on replay; stop on first failure to preserve order.

