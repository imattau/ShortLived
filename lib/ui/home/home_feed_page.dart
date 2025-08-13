import 'package:flutter/material.dart';
import 'widgets/video_player_view.dart';
import 'widgets/overlay_cluster.dart';
import '../sheets/create_sheet.dart';

class HomeFeedPage extends StatefulWidget {
  const HomeFeedPage({super.key});
  @override
  State<HomeFeedPage> createState() => _HomeFeedPageState();
}

class _HomeFeedPageState extends State<HomeFeedPage> {
  bool overlaysVisible = true;
  bool pausedBySheet = false;

  Future<void> _openCreate() async {
    setState(() => pausedBySheet = true);
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.black,
      builder: (ctx) => CreateSheet(onCreated: (post) {
        // TODO: route to controller to insert
        // We can find the nearest State of VideoPlayerView or keep a scoped controller
      }),
    );
    if (mounted) setState(() => pausedBySheet = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () {}, // play/pause will wire later
            onDoubleTap: () {}, // like will wire later
            onLongPress: () => setState(() => overlaysVisible = !overlaysVisible),
            child: const VideoPlayerView(),
          ),
          const _GradientScrim(top: true),
          const _GradientScrim(top: false),
          AnimatedOpacity(
            duration: const Duration(milliseconds: 220),
            opacity: overlaysVisible ? 1 : 0,
            child: OverlayCluster(onCreateTap: _openCreate),
          ),
          if (pausedBySheet)
            const Positioned(
              top: 8,
              left: 0,
              right: 0,
              child: Center(
                child: SizedBox(
                  key: Key('paused-banner'),
                  height: 6,
                  width: 80,
                ),
              ),
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
