abstract class KeyService {
  /// Returns pubkey (hex, 64 chars) or null if not set.
  Future<String?> getPubkey();
  /// Returns privkey (hex) or null if not set. Only used for signing; keep private.
  Future<String?> getPrivkey();

  /// Generate a new keypair and persist. Returns pubkey hex.
  Future<String> generate();
  /// Import an nsec (NIP-19) or raw hex; persists. Returns pubkey hex.
  Future<String> importSecret(String nsecOrHex);
  /// Export secret as nsec (never without explicit user action).
  Future<String?> exportNsec();
}
