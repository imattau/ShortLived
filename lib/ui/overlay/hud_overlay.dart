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

  const HudOverlay({
    super.key,
    required this.state,
    required this.controller,
    required this.onLikeLogical,
    this.onShareLogical,
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

  void _openSearch(BuildContext context) async {
    state.visible.value = false;
    await showModalBottomSheet(
      context: context,
      useRootNavigator: true,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF0E0E11),
      builder: (ctx) => Padding(
        padding: MediaQuery.of(ctx).viewInsets.add(const EdgeInsets.all(16)),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Search',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),
            const TextField(
              decoration: InputDecoration(
                hintText: 'Type to search…',
                hintStyle: TextStyle(color: Colors.white54),
                filled: true,
                fillColor: Color(0x22FFFFFF),
                border: OutlineInputBorder(
                  borderSide: BorderSide.none,
                  borderRadius: BorderRadius.all(Radius.circular(12)),
                ),
              ),
              style: TextStyle(color: Colors.white),
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Close'),
            ),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
    state.visible.value = true;
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
                      child: SafeArea(
                        child: Stack(
                          children: [
                            Positioned(
                              left: T.s24,
                              top: T.s24,
                              child: SearchPill(
                                onTap: () => _openSearch(context),
                              ),
                            ),
                            Positioned(
                              right: T.s24,
                              top: T.s24,
                              child: const SizedBox(
                                width: 48,
                                height: 48,
                                child: Center(child: AppIcon('bell_24')),
                              ),
                            ),
                            if (kIsWeb)
                              Positioned(
                                left: T.s24,
                                top: T.s24 + 56,
                                child: ValueListenableBuilder<bool>(
                                  valueListenable: controller.muted,
                                  builder: (_, muted, __) => ElevatedButton(
                                    onPressed: controller.toggleMute,
                                    child: Text(muted ? 'Unmute' : 'Mute'),
                                  ),
                                ),
                              ),
                            Builder(
                              builder: (ctx) {
                                final s = MediaQuery.of(ctx).size;
                                final bottomSafe = MediaQuery.of(
                                  ctx,
                                ).padding.bottom;
                                // Keep centre bias; reserve ~120px for the Create button footprint.
                                final baseBottom =
                                    (s.height * 0.22) + bottomSafe;
                                return Positioned(
                                  right: 20,
                                  bottom: baseBottom.clamp(100.0, 260.0),
                                  child: ValueListenableBuilder<HudModel>(
                                    valueListenable: state.model,
                                    builder: (_, m, __) => OverlayCluster(
                                      onLike: onLikeLogical,
                                      onComment: () {},
                                      onRepost: () {},
                                      onShare: onShareLogical ?? () {},
                                      onCopyLink: () {},
                                      onZap: () {},
                                      likeCount: m.likeCount,
                                      commentCount: m.commentCount,
                                      repostCount: m.repostCount,
                                      shareCount: m.shareCount,
                                      zapCount: m.zapCount,
                                    ),
                                  ),
                                );
                              },
                            ),
                            Positioned(
                              left: T.s24,
                              bottom: MediaQuery.of(context).size.height * 0.22,
                              child: ValueListenableBuilder<HudModel>(
                                valueListenable: state.model,
                                builder: (_, m, __) => BottomInfoBar(model: m),
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
                                        color: Colors.white.withValues(
                                          alpha: 0.85,
                                        ),
                                        width: 2,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  const Text(
                                    'Create',
                                    style: TextStyle(color: Colors.white),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
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
