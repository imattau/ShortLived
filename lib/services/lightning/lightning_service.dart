abstract class LightningService {
  Uri buildLnurl(String lud16, int millisats, {String? note});
  Stream<Map<String, dynamic>> listenForZapReceipts(String eventId);
}
