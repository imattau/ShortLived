enum NotificationType { reply, like, repost, zap }

class NotificationItem {
  final NotificationType type;
  final String id;              // event id
  final String fromPubkey;
  final String fromName;        // filled from MetadataService when available
  final String fromAvatar;      // optional
  final String relatedEventId;  // the post they acted on (if any)
  final String content;         // reply text or short label
  final int createdAt;          // seconds since epoch (nostr)
  final int? sats;              // for zaps (msats/1000 rounded)
  const NotificationItem({
    required this.type,
    required this.id,
    required this.fromPubkey,
    required this.fromName,
    required this.fromAvatar,
    required this.relatedEventId,
    required this.content,
    required this.createdAt,
    this.sats,
  });
}
