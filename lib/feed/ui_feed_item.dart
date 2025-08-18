/// Lightweight UI model the player/HUD can consume without
/// knowing about Nostr internals.
class UiFeedItem {
  final String eventId;
  final String authorPubkey;
  final String? authorDisplayName;
  final String? authorAvatarUrl;
  final Uri sourceUrl;        // playable url
  final Uri? hlsUrl;          // optional
  final Uri? mp4Url;          // optional
  final int likeCount;
  final int repostCount;
  final int replyCount;
  final String? lightning;    // lud16/lnurl

  const UiFeedItem({
    required this.eventId,
    required this.authorPubkey,
    required this.sourceUrl,
    this.hlsUrl,
    this.mp4Url,
    this.authorDisplayName,
    this.authorAvatarUrl,
    this.likeCount = 0,
    this.repostCount = 0,
    this.replyCount = 0,
    this.lightning,
  });
}
