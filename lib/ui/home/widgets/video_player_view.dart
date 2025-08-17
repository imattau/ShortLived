import 'package:flutter/material.dart';
import '../../../video/video_adapter.dart';

/// Basic video player that delegates to the current [VideoAdapter].
class VideoPlayerView extends StatelessWidget {
  const VideoPlayerView({
    super.key,
    required this.url,
    required this.autoplay,
    required this.muted,
    required this.fit,
    required this.onReady,
    this.onSkip,
    this.onUnsupported,
  });

  final String url;
  final bool autoplay;
  final bool muted;
  final BoxFit fit;
  final VideoReady onReady;
  final VoidCallback? onSkip;
  final void Function(String message)? onUnsupported;

  @override
  Widget build(BuildContext context) {
    final adapter = VideoScope.of(context);
    return adapter.build(
      url: url,
      autoplay: autoplay,
      muted: muted,
      fit: fit,
      onReady: onReady,
      onSkip: onSkip,
      onUnsupported: onUnsupported,
    );
  }
}
