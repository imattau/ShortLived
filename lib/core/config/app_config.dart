class AppConfig {
  // Enable real Nostr backend
  static const bool nostrEnabled =
      bool.fromEnvironment('NOSTR_ENABLED', defaultValue: false);

  // Prefer the web HLS path if available (safe fallback guards included)
  static const bool webHlsPreferred =
      bool.fromEnvironment('WEB_HLS_PREFERRED', defaultValue: true);
}
