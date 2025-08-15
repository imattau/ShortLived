abstract class Signer {
  /// Returns hex pubkey if available.
  Future<String?> getPubkey();

  /// Builds a signed Nostr event for (kind, content, tags).
  /// Must set `created_at` (seconds).
  Future<Map<String, dynamic>?> sign(int kind, String content, List<List<String>> tags);
}
