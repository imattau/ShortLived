import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../design/tokens.dart';
import '../widgets/app_icon.dart';
import '../home/widgets/overlay_cluster.dart';
import 'hud_model.dart';
import '../home/feed_controller.dart';
import 'widgets/search_pill.dart';
import 'widgets/bottom_info_bar.dart';

class HudOverlay extends StatelessWidget {
  final HudState state;
  final FeedController controller;
  final VoidCallback onLikeLogical;
  final VoidCallback? onShareLogical;
  final VoidCallback onSearch;
  final VoidCallback? onZap;

  const HudOverlay({
    super.key,
    required this.state,
    required this.controller,
    required this.onLikeLogical,
    this.onShareLogical,
    required this.onSearch,
    this.onZap,
  });
  void _toggleHud(BuildContext context) {
    final next = !state.visible.value;
    state.visible.value = next;
    if (!next) {
      final m = ScaffoldMessenger.maybeOf(context);
      m?.hideCurrentSnackBar();
      m?.showSnackBar(
        const SnackBar(
          content: Text(
            'HUD hidden. Long-press anywhere (or press H) to show.',
          ),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return CallbackShortcuts(
      bindings: <ShortcutActivator, VoidCallback>{
        const SingleActivator(LogicalKeyboardKey.arrowDown): controller.next,
        const SingleActivator(LogicalKeyboardKey.arrowUp): controller.prev,
        const SingleActivator(LogicalKeyboardKey.keyM): controller.toggleMute,
        const SingleActivator(LogicalKeyboardKey.keyL): onLikeLogical,
        const SingleActivator(LogicalKeyboardKey.keyH): () =>
            _toggleHud(context),
      },
      child: Focus(
        autofocus: true,
        child: Stack(
          fit: StackFit.expand,
          children: [
            GestureDetector(
              behavior: HitTestBehavior.translucent,
              onTap: () {
                if (!state.visible.value) state.visible.value = true;
              },
              onLongPress: () => _toggleHud(context),
              child: const SizedBox.expand(),
            ),
            ValueListenableBuilder<bool>(
              valueListenable: state.visible,
              builder: (context, visible, _) {
                return IgnorePointer(
                  ignoring: !visible,
                  child: AnimatedOpacity(
                    opacity: visible ? 1 : 0,
                    duration: const Duration(milliseconds: 150),
                    child: Material(
                      type: MaterialType.transparency,
                      child: Builder(builder: (context) {
                        final padding = MediaQuery.of(context).padding;
                        return Stack(
                          children: [
                            Positioned(
                              left: T.s24 + padding.left,
                              top: T.s24 + padding.top,
                              child: SearchPill(
                                onTap: onSearch,
                              ),
                            ),
                            Positioned(
                              right: T.s24 + padding.right,
                              top: T.s24 + padding.top,
                              child: const SizedBox(
                                width: 48,
                                height: 48,
                                child: Center(child: AppIcon('bell_24')),
                              ),
                            ),
                            if (kIsWeb)
                              Positioned(
                                left: T.s24 + padding.left,
                                top: T.s24 + padding.top + 56,
                                child: ValueListenableBuilder<bool>(
                                  valueListenable: controller.muted,
                                  builder: (_, muted, __) => ElevatedButton(
                                    onPressed: controller.toggleMute,
                                    child: Text(muted ? 'Unmute' : 'Mute'),
                                  ),
                                ),
                              ),
                            Builder(builder: (ctx) {
                              final s = MediaQuery.of(ctx).size;
                              final bottom = (s.height * 0.18 +
                                      MediaQuery.of(ctx).padding.bottom)
                                  .clamp(80.0, T.stackBottomReserve);
                              return Positioned(
                                right: T.stackSidePad + padding.right,
                                bottom: bottom,
                                child: ConstrainedBox(
                                  constraints: BoxConstraints(
                                    maxHeight:
                                        s.height - bottom - T.stackTopHeadroom,
                                  ),
                                  child: OverlayCluster(
                                    onLike: onLikeLogical,
                                    onComment: () {},
                                    onRepost: () {},
                                    onShare: onShareLogical ?? () {},
                                    onCopyLink: () {},
                                    onZap: onZap ?? () {},
                                    likeCount: state.model.value.likeCount,
                                    commentCount:
                                        state.model.value.commentCount,
                                    repostCount:
                                        state.model.value.repostCount,
                                    shareCount: state.model.value.shareCount,
                                    zapCount: state.model.value.zapCount,
                                  ),
                                ),
                              );
                            }),
                            Positioned(
                              left: T.s24 + padding.left,
                              bottom: MediaQuery.of(context).size.height * 0.22 +
                                  padding.bottom,
                              child: ValueListenableBuilder<HudModel>(
                                valueListenable: state.model,
                                builder: (_, m, __) => BottomInfoBar(model: m),
                              ),
                            ),
                          ],
                        );
                      }),
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
