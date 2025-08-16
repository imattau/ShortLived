import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../design/tokens.dart';
import '../widgets/app_icon.dart';
import '../home/widgets/overlay_cluster.dart';
import 'hud_model.dart';
import '../home/feed_controller.dart';

class HudOverlay extends StatelessWidget {
  final HudState state;
  final FeedController controller;
  final VoidCallback onLikeLogical;

  const HudOverlay({
    super.key,
    required this.state,
    required this.controller,
    required this.onLikeLogical,
  });

  @override
  Widget build(BuildContext context) {
    return CallbackShortcuts(
      bindings: <ShortcutActivator, VoidCallback>{
        const SingleActivator(LogicalKeyboardKey.arrowDown): controller.next,
        const SingleActivator(LogicalKeyboardKey.arrowUp): controller.prev,
        const SingleActivator(LogicalKeyboardKey.keyM): controller.toggleMute,
        const SingleActivator(LogicalKeyboardKey.keyL): onLikeLogical,
      },
      child: Focus(
        autofocus: true,
        child: ValueListenableBuilder<bool>(
          valueListenable: state.visible,
          builder: (_, visible, __) {
            final overlay = IgnorePointer(
              ignoring: !visible,
              child: SafeArea(
                child: Stack(
                  children: [
                    Positioned(
                      right: T.s24,
                      top: T.s24,
                      child: const SizedBox(
                        width: 48,
                        height: 48,
                        child: Center(child: AppIcon('bell_24')),
                      ),
                    ),
                    Positioned(
                      right: 20,
                      bottom: MediaQuery.of(context).size.height * 0.16,
                      child: ValueListenableBuilder<HudModel>(
                        valueListenable: state.model,
                        builder: (_, m, __) => OverlayCluster(
                          onLike: onLikeLogical,
                          onComment: () {},
                          onRepost: () {},
                          onShare: () {},
                          onCopyLink: () {},
                          onZap: () {},
                          likeCount: m.likeCount,
                          commentCount: m.commentCount,
                          repostCount: m.repostCount,
                          shareCount: m.shareCount,
                          zapCount: m.zapCount,
                        ),
                      ),
                    ),
                    Positioned(
                      left: T.s24,
                      right: T.s24,
                      bottom: MediaQuery.of(context).size.height * 0.22,
                      child: ValueListenableBuilder<HudModel>(
                        valueListenable: state.model,
                        builder: (_, m, __) => Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.10),
                            borderRadius: BorderRadius.circular(T.r16),
                          ),
                          child: Text(
                            m.caption,
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                        ),
                      ),
                    ),
                    if (kIsWeb)
                      Positioned(
                        left: T.s24,
                        bottom: MediaQuery.of(context).size.height * 0.28,
                        child: ValueListenableBuilder<bool>(
                          valueListenable: controller.muted,
                          builder: (_, muted, __) => ElevatedButton(
                            onPressed: controller.toggleMute,
                            child: Text(muted ? 'Unmute' : 'Mute'),
                          ),
                        ),
                      ),
                    Positioned(
                      left: 0,
                      right: 0,
                      bottom: T.s24,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 56,
                            height: 56,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(28),
                              border: Border.all(
                                color: Colors.white.withOpacity(0.85),
                                width: 2,
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),
                          const Text('Create', style: TextStyle(color: Colors.white)),
                        ],
                      ),
                    ),
                    Positioned.fill(
                      child: GestureDetector(
                        onLongPress: () => state.visible.value = !state.visible.value,
                        behavior: HitTestBehavior.translucent,
                      ),
                    ),
                  ],
                ),
              ),
            );

            return AnimatedOpacity(
              duration: const Duration(milliseconds: 150),
              opacity: visible ? 1 : 0,
              child: overlay,
            );
          },
        ),
      ),
    );
  }
}
