import 'package:flutter/material.dart';

import '../../widgets/app_icon.dart';

/// Vertical list of actions shown on the right side of the video.
///
/// The widget is given a finite width via [SizedBox] to avoid the
/// unconstrained `Stack` that previously caused layout exceptions on web.
class OverlayCluster extends StatelessWidget {
  final VoidCallback onLike;
  final VoidCallback onComment;
  final VoidCallback onRepost;
  final VoidCallback onShare;
  final VoidCallback onCopyLink;
  final VoidCallback onZap;

  const OverlayCluster({
    super.key,
    required this.onLike,
    required this.onComment,
    required this.onRepost,
    required this.onShare,
    required this.onCopyLink,
    required this.onZap,
  });

  /// Size of each square action button.
  static const double kActionSize = 44;

  /// Gap between action buttons.
  static const double kGap = 14;

  @override
  Widget build(BuildContext context) {
    // Bounded width ensures finite constraints; height is determined by content.
    return SizedBox(
      width: kActionSize,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          _Action(
            icon: 'heart_24',
            label: '12.3k',
            keyName: 'like',
            onTap: onLike,
          ),
          const SizedBox(height: kGap),
          _Action(
            icon: 'comment_24',
            label: '885',
            keyName: 'comment',
            onTap: onComment,
          ),
          const SizedBox(height: kGap),
          _Action(
            icon: 'repost_24',
            label: '97',
            keyName: 'repost',
            onTap: onRepost,
          ),
          const SizedBox(height: kGap),
          _Action(
            icon: 'share_24',
            label: '87',
            keyName: 'share',
            onTap: onShare,
          ),
          const SizedBox(height: kGap),
          _Action(
            icon: 'bookmark_24',
            label: '—',
            keyName: 'save',
            onTap: onCopyLink,
          ),
          const SizedBox(height: kGap),
          _Action(icon: 'bolt_24', label: '42', keyName: 'zap', onTap: onZap),
        ],
      ),
    );
  }
}

class _Action extends StatelessWidget {
  final String icon;
  final String label;
  final String keyName;
  final VoidCallback onTap;

  const _Action({
    required this.icon,
    required this.label,
    required this.keyName,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: OverlayCluster.kActionSize,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          GestureDetector(
            onTap: onTap,
            child: Container(
              width: OverlayCluster.kActionSize,
              height: OverlayCluster.kActionSize,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.10),
                borderRadius: BorderRadius.circular(
                  OverlayCluster.kActionSize / 2,
                ),
              ),
              alignment: Alignment.center,
              child: AppIcon(icon),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            label,
            key: Key('count_$keyName'),
            style: const TextStyle(fontSize: 12, color: Colors.white70),
          ),
        ],
      ),
    );
  }
}
