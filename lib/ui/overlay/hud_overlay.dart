import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../design/tokens.dart';
import '../widgets/app_icon.dart';
import '../home/widgets/overlay_cluster.dart';
import 'hud_model.dart';
import '../home/feed_controller.dart';
import 'widgets/search_pill.dart';
import 'widgets/author_header.dart';
import 'widgets/npub_pill.dart';

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

  void _openSearch(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF0E0E11),
      isScrollControlled: true,
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
  }

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
              child: Material(
                type: MaterialType.transparency,
                child: SafeArea(
                  child: Stack(
                    children: [
                      Positioned(
                        left: T.s24,
                        top: T.s24,
                        child: SearchPill(onTap: () => _openSearch(context)),
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
                      Positioned(
                        left: T.s24,
                        top: T.s24 + 56,
                        child: ValueListenableBuilder<HudModel>(
                          valueListenable: state.model,
                          builder: (_, m, __) => AuthorHeader(
                            display: m.authorDisplay,
                            npubShort: m.authorNpub,
                            onAvatarTap: () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                    content: Text('Open profile for ${m.authorDisplay}')),
                              );
                            },
                          ),
                        ),
                      ),
                      Positioned(
                        right: 20,
                        bottom:
                            MediaQuery.of(context).size.height * 0.16,
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
                        bottom:
                            MediaQuery.of(context).size.height * 0.22,
                        child: ValueListenableBuilder<HudModel>(
                          valueListenable: state.model,
                          builder: (_, m, __) => Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.10),
                              borderRadius: BorderRadius.circular(T.r16),
                            ),
                            child: Text(
                              m.caption,
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                          ),
                        ),
                      ),
                      Positioned(
                        left: T.s24,
                        bottom:
                            MediaQuery.of(context).size.height * 0.30,
                        child: ValueListenableBuilder<HudModel>(
                          valueListenable: state.model,
                          builder: (_, m, __) => NpubPill(npub: m.authorNpub),
                        ),
                      ),
                      if (kIsWeb)
                        Positioned(
                          left: T.s24,
                          bottom:
                              MediaQuery.of(context).size.height * 0.28,
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
                                  color:
                                      Colors.white.withValues(alpha: 0.85),
                                  width: 2,
                                ),
                              ),
                            ),
                            const SizedBox(height: 8),
                            const Text('Create',
                                style: TextStyle(color: Colors.white)),
                          ],
                        ),
                      ),
                      Positioned.fill(
                        child: GestureDetector(
                          onLongPress: () =>
                              state.visible.value = !state.visible.value,
                          behavior: HitTestBehavior.translucent,
                        ),
                      ),
                    ],
                  ),
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
