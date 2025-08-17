// Configuration values for Nostr networking.

// Add more relays (websocket friendly)
const List<String> kDefaultRelays = <String>[
  'wss://relay.damus.io',
  'wss://nos.lol',
  'wss://relay.snort.social',
  'wss://eden.nostr.land',
  'wss://nostr.fmt.wiz.biz',
];

/// How many items to request initially.
const int kNostrInitialLimit = 80;

/// Timeout for initial load before showing empty state.
const Duration kNostrLoadTimeout = Duration(seconds: 6);
