import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import '../../../data/models/post.dart';
import 'real_video_view.dart';

class VideoCard extends StatelessWidget {
  final Post post;
  final bool isCurrent;
  final bool isNeighbour;
  final VideoPlayerController? controller; // null if not active
  final bool globalPaused;
  const VideoCard({
    super.key,
    required this.post,
    required this.isCurrent,
    required this.isNeighbour,
    required this.controller,
    required this.globalPaused,
  });

  @override
  Widget build(BuildContext context) {
    final isPlaying = isCurrent && !globalPaused && controller != null;
    return Stack(
      fit: StackFit.expand,
      children: [
        if (controller != null)
          RealVideoView(controller: controller!, isActive: isCurrent || isNeighbour, isPlaying: isPlaying)
        else
          // Not active: black placeholder to save resources
          const ColoredBox(color: Colors.black),
        // Optional tiny label for tests/dev
        Positioned(
          left: 8, top: 8,
          child: Text(
            isPlaying ? 'Playing' : (isNeighbour ? 'Preloaded' : 'Idle'),
            style: const TextStyle(fontSize: 10, color: Colors.white),
          ),
        ),
      ],
    );
  }
}
