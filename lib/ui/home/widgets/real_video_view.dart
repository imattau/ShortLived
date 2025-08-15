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
  bool _webMuted = kIsWeb; // start muted only on web
  @override
  void initState() {
    super.initState();
    if (kIsWeb) {
      widget.controller.setVolume(0);
    }
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
    // Overlay a small unmute button on web when muted
    return Stack(
      fit: StackFit.expand,
      children: [
        player,
        if (_webMuted)
          Positioned(
            bottom: 24,
            left: 16,
            child: ElevatedButton.icon(
              icon: const Icon(Icons.volume_up),
              label: const Text('Unmute'),
              onPressed: () {
                setState(() => _webMuted = false);
                widget.controller.setVolume(1.0);
              },
            ),
          ),
      ],
    );
  }

  @override
  bool get wantKeepAlive => true;
}
