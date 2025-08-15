abstract class RelayService {
  Future<void> init(List<String> relays);
  /// Subscribe to feed using Nostr filters; returns a subscription id you can close later.
  Future<String> subscribe(List<Map<String, dynamic>> filters, {String? subId});
  Future<void> close(String subId);
  Stream<List<dynamic>> subscribeFeed(
      {required List<String> authors, String? hashtag});
  /// Publish already signed event JSON (has id/pubkey/sig).
  Future<String> publishEvent(Map<String, dynamic> signedEventJson);

  /// High-level helpers now require signing context; implementations can call KeyService.
  Future<void> like({required String eventId});
  Future<void> reply({
    required String parentId,
    required String content,
    String? parentPubkey,
    String? rootId,
    String? rootPubkey,
  });
  Future<void> repost({required String eventId, String? originalJson});
  Future<void> zapRequest({required String eventId, required int millisats});

  /// Broadcast of raw event objects (Nostr event JSON map)
  Stream<Map<String, dynamic>> get events;

  /// Build a signed NIP-57 zap request event (kind 9734).
  Future<Map<String, dynamic>> buildZapRequest({
    required String recipientPubkey,
    required String eventId,
    String content,
    List<String>? relays,
  });
}
