import 'package:flutter/material.dart';
import 'widgets/video_player_view.dart';
import 'widgets/overlay_cluster.dart';

class HomeFeedPage extends StatefulWidget {
  const HomeFeedPage({super.key});
  @override
  State<HomeFeedPage> createState() => _HomeFeedPageState();
}

class _HomeFeedPageState extends State<HomeFeedPage> {
  bool playing = true; // mocked for now
  bool overlaysVisible = true; // wired to controller later

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Video layer (will become PageView in PR 3)
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () => setState(() => playing = !playing),
            onDoubleTap: () {
              // TODO: trigger mock like + heart animation
            },
            onLongPress: () => setState(() => overlaysVisible = !overlaysVisible),
            child: const VideoPlayerView(), // placeholder black screen
          ),
          // Scrims
          const _GradientScrim(top: true),
          const _GradientScrim(top: false),
          // Overlays
          AnimatedOpacity(
            duration: const Duration(milliseconds: 220),
            opacity: overlaysVisible ? 1 : 0,
            child: const OverlayCluster(),
          ),
        ],
      ),
    );
  }
}

class _GradientScrim extends StatelessWidget {
  final bool top;
  const _GradientScrim({required this.top});
  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      ignoring: true,
      child: Align(
        alignment: top ? Alignment.topCenter : Alignment.bottomCenter,
        child: Container(
          height: 140,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: top ? Alignment.topCenter : Alignment.bottomCenter,
              end: top ? Alignment.bottomCenter : Alignment.topCenter,
              colors: const [Colors.black54, Colors.transparent],
            ),
          ),
        ),
      ),
    );
  }
}
