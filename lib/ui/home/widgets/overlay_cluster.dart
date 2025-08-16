import 'package:flutter/material.dart';

import '../../widgets/app_icon.dart';

class OverlayCluster extends StatelessWidget {
  final VoidCallback onLike;
  final VoidCallback onComment;
  final VoidCallback onRepost;
  final VoidCallback onShare;
  final VoidCallback? onCopyLink;
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
    this.onCopyLink,
    required this.onZap,
    this.likeCount = '12.3k',
    this.commentCount = '885',
    this.repostCount = '97',
    this.shareCount = '87',
    this.zapCount = '42',
  });

  @override
  Widget build(BuildContext context) {
    // Responsive scaling around iPhone 12 width (≈390).
    final w = MediaQuery.of(context).size.shortestSide;
    double scale = (w / 390).clamp(0.85, 1.05);
    final actionSize = 44.0 * scale; // button circle
    final gap = 10.0 * scale; // vertical gap
    final labelSize = 11.0 * scale;

    Widget item(String icon, String count, VoidCallback onTap) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(actionSize / 2),
            child: Container(
              width: actionSize,
              height: actionSize,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.10),
                borderRadius: BorderRadius.circular(actionSize / 2),
              ),
              alignment: Alignment.center,
              child: AppIcon(icon, size: 22 * scale, color: Colors.white),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            count,
            style: TextStyle(fontSize: labelSize, color: Colors.white70),
          ),
        ],
      );
    }

    final children = <Widget>[
      item('heart_24', likeCount, onLike),
      SizedBox(height: gap),
      item('comment_24', commentCount, onComment),
      SizedBox(height: gap),
      item('repost_24', repostCount, onRepost),
      SizedBox(height: gap),
      item('share_24', shareCount, onShare),
    ];

    if (onCopyLink != null) {
      children.add(SizedBox(height: gap));
      children.add(item('bookmark_24', '—', onCopyLink!));
    }

    children.add(SizedBox(height: gap));
    children.add(item('zap_24', zapCount, onZap));

    return SizedBox(
      width: actionSize,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: children,
      ),
    );
  }
}

