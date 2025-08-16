import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'video_adapter.dart';

class RealVideoAdapter implements VideoAdapter {
  @override
  Widget build({
    required String url,
    required bool autoplay,
    required bool muted,
    required BoxFit fit,
    required VideoReady onReady,
    Key? key,
  }) {
    return _RealVideo(
      key: key,
      url: url,
      autoplay: autoplay,
      muted: muted,
      fit: fit,
      onReady: onReady,
    );
  }
}

class _RealVideo extends StatefulWidget {
  final String url;
  final bool autoplay;
  final bool muted;
  final BoxFit fit;
  final VideoReady onReady;
  const _RealVideo({
    super.key,
    required this.url,
    required this.autoplay,
    required this.muted,
    required this.fit,
    required this.onReady,
  });

  @override
  State<_RealVideo> createState() => _RealVideoState();
}

class _RealVideoState extends State<_RealVideo> {
  late final VideoPlayerController _c;
  bool _readyCalled = false;

  @override
  void initState() {
    super.initState();
    _c = VideoPlayerController.networkUrl(Uri.parse(widget.url));
    _c.initialize().then((_) async {
      if (!mounted) return;
      await _c.setLooping(true);
      await _c.setVolume(widget.muted ? 0.0 : 1.0);
      if (widget.autoplay) {
        WidgetsBinding.instance.addPostFrameCallback((_) => _c.play());
      }
      if (!_readyCalled) {
        _readyCalled = true;
        widget.onReady();
      }
      setState(() {});
    });
  }

  @override
  void didUpdateWidget(covariant _RealVideo oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.muted != widget.muted) {
      _c.setVolume(widget.muted ? 0.0 : 1.0);
    }
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_c.value.isInitialized) {
      return const SizedBox.expand();
    }
    return FittedBox(
      fit: widget.fit,
      clipBehavior: Clip.hardEdge,
      child: SizedBox(
        width: _c.value.size.width,
        height: _c.value.size.height,
        child: VideoPlayer(_c),
      ),
    );
  }
}
