import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../design/tokens.dart';
import '../widgets/app_icon.dart';
import 'widgets/overlay_cluster.dart';
import 'widgets/feed_pager.dart';
import '../../feed/demo_feed.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool _overlaysVisible = true;
  bool _muted = true;
  int _current = 0;

  void _onChanged(int i) => setState(() => _current = i);

  @override
  Widget build(BuildContext context) {
    final item = demoFeed[_current];
    return GestureDetector(
      key: const Key('feed-gesture'),
      onLongPress: () => setState(() => _overlaysVisible = !_overlaysVisible),
      child: Scaffold(
        backgroundColor: T.bg,
        body: Stack(
          children: [
            // FEED
            Positioned.fill(
              child: FeedPager(
                items: demoFeed,
                muted: _muted,
                onIndexChanged: _onChanged,
              ),
            ),
            AnimatedOpacity(
              opacity: _overlaysVisible ? 1 : 0,
              duration: const Duration(milliseconds: 150),
              child: IgnorePointer(
                ignoring: !_overlaysVisible,
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
                        right: T.s24,
                        bottom: MediaQuery.of(context).size.height * 0.16,
                        child: OverlayCluster(
                          onLike: () {},
                          onComment: () {},
                          onRepost: () {},
                          onShare: () {},
                          onCopyLink: () {},
                          onZap: () {},
                          likeCount: item.likeCount,
                          commentCount: item.commentCount,
                          repostCount: item.repostCount,
                          shareCount: item.shareCount,
                          zapCount: item.zapCount,
                        ),
                      ),
                      Positioned(
                        left: T.s24,
                        right: T.s24,
                        bottom: MediaQuery.of(context).size.height * 0.22,
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.10),
                            borderRadius: BorderRadius.circular(T.r16),
                          ),
                          child: Text(
                            item.caption,
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                        ),
                      ),
                      if (kIsWeb)
                        Positioned(
                          left: T.s24,
                          bottom: MediaQuery.of(context).size.height * 0.28,
                          child: ElevatedButton(
                            onPressed: () => setState(() => _muted = !_muted),
                            child: Text(_muted ? 'Unmute' : 'Mute'),
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
                                  color: Colors.white.withValues(alpha: 0.85),
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
          ],
        ),
      ),
    );
  }
}
