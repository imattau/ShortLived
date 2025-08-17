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
    return LayoutBuilder(
      builder: (ctx, constraints) {
        // Available vertical space for the column. We reserve a little
        // headroom so it never kisses top/bottom chrome.
        final avail = constraints.maxHeight.clamp(200.0, 1200.0);

        // Estimate height of rows that show a numeric label vs. icon only.
        const labelLine = 11.0; // labelSmall font size with height 1.0
        const rowWithLabel = T.btnSize + T.btnGap + labelLine; // icon+gap+label
        const rowNoLabel = T.btnSize;

        // Six actions, one of which (bookmark) has no label.
        const labelledRows = 5;
        const noLabelRows = 1;
        const spacers = 6 - 1;
        final rowsHeight =
            labelledRows * rowWithLabel + noLabelRows * rowNoLabel;

        // Ideal free space to distribute as gaps.
        final free = avail - rowsHeight;
        double gap;
        if (free <= 0) {
          gap = T.stackGapMin;
        } else {
          final ideal = free / spacers;
          gap = ideal.clamp(T.stackGapMin, T.stackGapMax);
        }

        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ActionButton(
              icon: 'heart_24',
              label: likeCount,
              onTap: onLike,
              tooltip: 'Like',
            ),
            SizedBox(height: gap),
            ActionButton(
              icon: 'comment_24',
              label: commentCount,
              onTap: onComment,
              tooltip: 'Comments',
            ),
            SizedBox(height: gap),
            ActionButton(
              icon: 'repost_24',
              label: repostCount,
              onTap: onRepost,
              tooltip: 'Repost',
            ),
            SizedBox(height: gap),
            ActionButton(
              icon: 'bookmark_24',
              label: null,
              onTap: onCopyLink,
              tooltip: 'Save',
            ),
            SizedBox(height: gap),
            ActionButton(
              icon: 'share_24',
              label: shareCount,
              onTap: onShare,
              tooltip: 'Share',
            ),
            SizedBox(height: gap),
            ActionButton(
              icon: 'zap_24',
              label: zapCount,
              onTap: onZap,
              tooltip: 'Zap',
            ),
          ],
        );
      },
    );
  }
}
