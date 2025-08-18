import 'package:flutter_test/flutter_test.dart';
import 'package:nostr_video/services/nostr/events/zap_request_event.dart';

void main() {
  test('builds 9734 with p,e,amount,relays', () {
    final b = ZapRequestBuilder(
      recipientPubkey: 'pk_recipient',
      targetEventId: 'note123',
      amountMsat: 21000,
      relays: ['wss://relay.example', 'wss://r2'],
      createdAt: 1700000000,
    );
    final m = b.toUnsigned(pubkey: 'pk_me');
    expect(m['kind'], 9734);
    expect(m['created_at'], 1700000000);
    final tags = (m['tags'] as List).cast<List>();
    expect(tags.any((t) => t[0] == 'p' && t[1] == 'pk_recipient'), true);
    expect(tags.any((t) => t[0] == 'e' && t[1] == 'note123'), true);
    expect(tags.any((t) => t[0] == 'amount' && t[1] == '21000'), true);
    expect(tags.any((t) => t[0] == 'relays'), true);
  });
}
