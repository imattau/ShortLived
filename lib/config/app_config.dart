import 'package:flutter/foundation.dart';

/// Build flag: flutter run -d chrome --dart-define=NOSTR_ENABLED=true
const bool kNostrEnabled = bool.fromEnvironment('NOSTR_ENABLED', defaultValue: false);

/// Default relays (edit to taste, or load from settings later).
const List<String> kDefaultRelays = <String>[
  'wss://relay.damus.io',
  'wss://nos.lol',
];

/// How many items to request initially.
const int kNostrInitialLimit = 50;
