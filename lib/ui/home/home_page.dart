import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../design/tokens.dart';
import '../widgets/app_icon.dart';
import 'widgets/overlay_cluster.dart';
import 'widgets/video_player_view.dart';

/// CORS-safe demo video for web; replace with real feed when plugged in.
const _demoVideo =
    'https://flutter.github.io/assets-for-api-docs/assets/videos/bee.mp4';

class HomePage extends StatefulWidget {
  const HomePage({super.key});
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool _overlaysVisible = true;
  bool _muted = true;

  static void _noop() {}

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onLongPress: () => setState(() => _overlaysVisible = !_overlaysVisible),
      child: Scaffold(
        backgroundColor: T.bg,
        body: Stack(
          children: [
            Positioned.fill(
              child: VideoPlayerView(
                url: _demoVideo,
                autoplay: true,
                muted: _muted,
                fit: BoxFit.cover,
                onReady: () {},
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
                        child: const OverlayCluster(
                          onLike: _noop,
                          onComment: _noop,
                          onRepost: _noop,
                          onShare: _noop,
                          onCopyLink: _noop,
                          onZap: _noop,
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
                          child: RichText(
                            text: TextSpan(
                              style: Theme.of(context).textTheme.bodyMedium,
                              children: const [
                                TextSpan(text: 'Enjoying a sunny day '),
                                TextSpan(
                                  text: '#nature ',
                                  style: TextStyle(color: T.blue),
                                ),
                                TextSpan(
                                  text: '#sydney ',
                                  style: TextStyle(color: T.blue),
                                ),
                                TextSpan(
                                  text: '#nostr',
                                  style: TextStyle(color: T.blue),
                                ),
                              ],
                            ),
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
