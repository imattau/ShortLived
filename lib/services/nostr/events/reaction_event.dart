/// NIP-25 reaction (kind 7) builder.
/// content: usually "+" for like (or an emoji).
class ReactionEventBuilder {
  final String content; // e.g. "+"
  final String targetEventId; // referenced "e" tag
  final String targetAuthorPubkey; // referenced "p" tag
  final int createdAt;

  ReactionEventBuilder({
    required this.content,
    required this.targetEventId,
    required this.targetAuthorPubkey,
    int? createdAt,
  }) : createdAt = createdAt ?? DateTime.now().millisecondsSinceEpoch ~/ 1000;

  List<List<String>> toTags() => [
        ["e", targetEventId],
        ["p", targetAuthorPubkey],
      ];

  Map<String, dynamic> toUnsigned({required String pubkey}) {
    return {
      "kind": 7,
      "content": content,
      "created_at": createdAt,
      "pubkey": pubkey,
      "tags": toTags(),
    };
  }

  /// Returns signed event map via [signer].
  Future<Map<String, dynamic>> signWith(
      Future<Map<String, dynamic>> Function(Map<String, dynamic>) signer,
      {required String pubkey}) async {
    final unsigned = toUnsigned(pubkey: pubkey);
    final signed = await signer(unsigned);
    return signed;
  }
}
