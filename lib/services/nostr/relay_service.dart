abstract class RelayService {
  Future<void> init(List<String> relays);
  /// Subscribe to feed using Nostr filters; returns a subscription id you can close later.
  Future<String> subscribe(List<Map<String, dynamic>> filters, {String? subId});
  Future<void> close(String subId);
  Stream<List<dynamic>> subscribeFeed(
      {required List<String> authors, String? hashtag});
  Future<String> publishEvent(Map<String, dynamic> eventJson);
  Future<void> like({required String eventId});
  Future<void> reply(
      {required String parentId,
      required String content,
      String? parentPubkey});
  Future<void> zapRequest({required String eventId, required int millisats});

  /// Broadcast of raw event objects (Nostr event JSON map)
  Stream<Map<String, dynamic>> get events;
}
