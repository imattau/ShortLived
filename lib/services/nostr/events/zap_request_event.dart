/// NIP-57 Zap Request (kind 9734)
/// Required tags:
///  - ['p', <recipient pubkey>]
/// Optional tags:
///  - ['e', <target note id>]
///  - ['amount', '<millisats>']
///  - ['relays', '<relay1>', '<relay2>', ...]
class ZapRequestBuilder {
  final String recipientPubkey;
  final String? targetEventId;
  final int amountMsat;
  final List<String> relays;
  final int createdAt;
  final String content;

  ZapRequestBuilder({
    required this.recipientPubkey,
    this.targetEventId,
    required this.amountMsat,
    this.relays = const [],
    this.content = '',
    int? createdAt,
  }) : createdAt = createdAt ?? DateTime.now().millisecondsSinceEpoch ~/ 1000;

  Map<String, dynamic> toUnsigned({required String pubkey}) {
    final tags = <List<String>>[
      ['p', recipientPubkey],
      ['amount', amountMsat.toString()],
    ];
    if (targetEventId != null && targetEventId!.isNotEmpty) {
      tags.add(['e', targetEventId!]);
    }
    if (relays.isNotEmpty) {
      tags.add(['relays', ...relays]);
    }
    return {
      'kind': 9734,
      'content': content,
      'created_at': createdAt,
      'pubkey': pubkey,
      'tags': tags,
    };
  }
}
