import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import '../../../data/models/post.dart';
import 'real_video_view.dart';
import '../../../core/testing/test_switches.dart';
import '../../widgets/blur_shield.dart';
import '../../widgets/hashtag_text.dart';

class VideoCard extends StatefulWidget {
  final Post post;
  final bool isCurrent;
  final bool isNeighbour;
  final VideoPlayerController? controller; // null if not active
  final bool globalPaused;
  final bool blurBySafety; // NEW: parent decides if safety blur applies for this post
  const VideoCard({
    super.key,
    required this.post,
    required this.isCurrent,
    required this.isNeighbour,
    required this.controller,
    required this.globalPaused,
    required this.blurBySafety,
  });

  @override
  State<VideoCard> createState() => _VideoCardState();
}

class _VideoCardState extends State<VideoCard> {
  bool revealed = false;

  @override
  Widget build(BuildContext context) {
    final isPlaying = widget.isCurrent &&
        !widget.globalPaused &&
        (widget.controller != null || TestSwitches.disableVideo) &&
        !(widget.blurBySafety && !revealed);

    return Stack(
      fit: StackFit.expand,
      children: [
        if (widget.controller != null)
          RealVideoView(
            controller: widget.controller!,
            isActive: widget.isCurrent || widget.isNeighbour,
            isPlaying: isPlaying,
          )
        else
          // Not active: black placeholder to save resources
          const ColoredBox(color: Colors.black),
        // Optional tiny label for tests/dev
        Positioned(
          left: 8,
          top: 8,
          child: Text(
            isPlaying
                ? 'Playing'
                : (widget.isNeighbour ? 'Preloaded' : 'Idle'),
            style: const TextStyle(fontSize: 10, color: Colors.white),
          ),
        ),
        // Blur safety shield
        BlurShield(
          visible: widget.blurBySafety && !revealed,
          onReveal: () => setState(() => revealed = true),
        ),
        Positioned(
          left: 12,
          right: 12,
          bottom: 12,
          child: HashtagText(
            widget.post.caption,
            style: const TextStyle(color: Colors.white),
          ),
        ),
      ],
    );
  }
}
