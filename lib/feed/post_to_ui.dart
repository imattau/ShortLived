import 'package:flutter/foundation.dart' show kIsWeb;
import 'ui_feed_item.dart';
import '../data/models/post.dart';

/// Pick the most compatible source:
/// - On Web: prefer mp4 if present (widest support), else hls.
/// - Elsewhere: prefer hls, else mp4.
Uri _chooseBestSource({Uri? mp4, Uri? hls}) {
  if (kIsWeb) {
    return mp4 ?? hls ?? Uri.parse('');
  }
  return hls ?? mp4 ?? Uri.parse('');
}

UiFeedItem uiFromPost(Post p) {
  final uri = Uri.parse(p.url);
  final lower = p.url.toLowerCase();
  Uri? mp4;
  Uri? hls;
  if (lower.endsWith('.mp4')) mp4 = uri;
  if (lower.endsWith('.m3u8')) hls = uri;
  final source = _chooseBestSource(mp4: mp4, hls: hls);

  return UiFeedItem(
    eventId: p.id,
    authorPubkey: p.author.pubkey,
    authorDisplayName: p.author.name,
    authorAvatarUrl: p.author.avatarUrl.isEmpty ? null : p.author.avatarUrl,
    mp4Url: mp4,
    hlsUrl: hls,
    sourceUrl: source,
    likeCount: p.likeCount,
    repostCount: p.repostCount,
    replyCount: p.commentCount,
  );
}
