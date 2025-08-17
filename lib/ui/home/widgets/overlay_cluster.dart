import 'package:flutter/material.dart';
import '../../design/tokens.dart';
import '../../overlay/widgets/action_button.dart';
import '../../../utils/capabilities.dart';

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

  double _gapForHeight(double h) {
    if (h < 560) return T.stackGapMin; // very tight
    if (h < 720) return T.stackGapMed; // tight
    return T.stackGapMax; // comfy
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (_, c) {
      final gap = _gapForHeight(c.maxHeight);

      Widget row(String icon, String? count, VoidCallback onTap, String tip) =>
          Padding(
            padding: EdgeInsets.only(bottom: gap),
            child: ActionButton(icon: icon, label: count, onTap: onTap, tooltip: tip),
          );

      final children = <Widget>[
        row('heart_24',    likeCount,    onLike,    'Like'),
        row('comment_24',  commentCount, onComment, 'Comments'),
        row('repost_24',   repostCount,  onRepost,  'Repost'),
        row('bookmark_24', null,         onCopyLink,'Save'),
        if (Capabilities.shareSupported)
          row('share_24',    shareCount,   onShare,   'Share'),
        Padding(
          padding: EdgeInsets.only(bottom: 0), // last item no extra gap
          child: ActionButton(icon: 'zap_24', label: zapCount, onTap: onZap, tooltip: 'Zap'),
        ),
      ];
      return Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: children,
      );
    });
  }
}

