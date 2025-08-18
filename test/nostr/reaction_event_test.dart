import 'package:flutter_test/flutter_test.dart';
import 'package:nostr_video/services/nostr/events/reaction_event.dart';

void main() {
  test('builds unsigned reaction event (kind 7) with e/p tags', () {
    final b = ReactionEventBuilder(
      content: '+',
      targetEventId: 'evt123',
      targetAuthorPubkey: 'pkabc',
      createdAt: 1700000000,
    );
    final m = b.toUnsigned(pubkey: 'mypk');
    expect(m['kind'], 7);
    expect(m['content'], '+');
    expect(m['created_at'], 1700000000);
    expect((m['tags'] as List).length, 2);
    expect((m['tags'] as List)[0][0], 'e');
    expect((m['tags'] as List)[0][1], 'evt123');
    expect((m['tags'] as List)[1][0], 'p');
    expect((m['tags'] as List)[1][1], 'pkabc');
  });
}
