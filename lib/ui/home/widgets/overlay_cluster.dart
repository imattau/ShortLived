import 'package:flutter/material.dart';

import '../../design/tokens.dart';
import '../../overlay/widgets/action_button.dart';

class OverlayCluster extends StatelessWidget {
  final VoidCallback onLike;
  final VoidCallback onComment;
  final VoidCallback onRepost;
  final VoidCallback onShare;
  final VoidCallback onCopyLink;
  final VoidCallback onZap;

  final String likeCount;
  final String commentCount;
  final String repostCount;
  final String shareCount;
  final String zapCount;

  const OverlayCluster({
    super.key,
    required this.onLike,
    required this.onComment,
    required this.onRepost,
    required this.onShare,
    required this.onCopyLink,
    required this.onZap,
    required this.likeCount,
    required this.commentCount,
    required this.repostCount,
    required this.shareCount,
    required this.zapCount,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        ActionButton(icon: 'heart_24', label: likeCount, onTap: onLike, tooltip: 'Like'),
        const SizedBox(height: T.stackGap),
        ActionButton(icon: 'comment_24', label: commentCount, onTap: onComment, tooltip: 'Comments'),
        const SizedBox(height: T.stackGap),
        ActionButton(icon: 'repost_24', label: repostCount, onTap: onRepost, tooltip: 'Repost'),
        const SizedBox(height: T.stackGap),
        ActionButton(icon: 'bookmark_24', label: null, onTap: onCopyLink, tooltip: 'Save'),
        const SizedBox(height: T.stackGap),
        ActionButton(icon: 'share_24', label: shareCount, onTap: onShare, tooltip: 'Share'),
        const SizedBox(height: T.stackGap),
        ActionButton(icon: 'zap_24', label: zapCount, onTap: onZap, tooltip: 'Zap'),
      ],
    );
  }
}
