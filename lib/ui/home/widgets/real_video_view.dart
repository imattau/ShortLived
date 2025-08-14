import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:video_player/video_player.dart';

class RealVideoView extends StatefulWidget {
  const RealVideoView({super.key, required this.controller, required this.isActive, required this.isPlaying});
  final VideoPlayerController controller;
  final bool isActive;   // within ±1 window
  final bool isPlaying;  // current item and not globally paused

  @override
  State<RealVideoView> createState() => _RealVideoViewState();
}

class _RealVideoViewState extends State<RealVideoView> with AutomaticKeepAliveClientMixin {
  @override
  void initState() {
    super.initState();
    _maybePlayPause();
  }

  @override
  void didUpdateWidget(covariant RealVideoView oldWidget) {
    super.didUpdateWidget(oldWidget);
    _maybePlayPause();
  }

  Future<void> _maybePlayPause() async {
    if (!widget.controller.value.isInitialized) return;
    if (widget.isPlaying) {
      await widget.controller.play();
    } else {
      await widget.controller.pause();
      await widget.controller.seekTo(Duration.zero);
    }
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    if (!widget.controller.value.isInitialized) {
      return const ColoredBox(color: Colors.black);
    }
    final player = FittedBox(
      fit: BoxFit.cover,
      child: SizedBox(
        width: widget.controller.value.size.width,
        height: widget.controller.value.size.height,
        child: VideoPlayer(widget.controller),
      ),
    );
    if (!kIsWeb) return player;
    // On web: single tap toggles mute so users can enable sound per video.
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () async {
        final v = widget.controller.value.volume;
        await widget.controller.setVolume(v > 0 ? 0.0 : 1.0);
      },
      child: player,
    );
  }

  @override
  bool get wantKeepAlive => true;
}
