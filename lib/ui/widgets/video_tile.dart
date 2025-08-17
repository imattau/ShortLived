import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:visibility_detector/visibility_detector.dart';
import '../../video/video_lifecycle.dart';

typedef OnPrefetch = Future<void> Function();

class VideoTile extends StatefulWidget {
  const VideoTile({
    super.key,
    required this.lifecycle,
    required this.onPrefetchNext,
  });
  final VideoLifecycle lifecycle;
  final OnPrefetch onPrefetchNext;
  @override
  State<VideoTile> createState() => _VideoTileState();
}

class _VideoTileState extends State<VideoTile> {
  bool _error = false;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    final c = widget.lifecycle.controller;
    _loading = !(c?.value.isInitialized ?? false);
    c?.addListener(_onControllerChanged);
    if (c != null && c.value.isInitialized) {
      widget.onPrefetchNext();
    }
  }

  void _onControllerChanged() {
    final c = widget.lifecycle.controller!;
    final v = c.value;
    if (!mounted) return;
    setState(() {
      _loading = !v.isInitialized;
      _error = v.hasError;
    });
    if (v.isInitialized) {
      widget.onPrefetchNext();
    }
  }

  @override
  void dispose() {
    widget.lifecycle.controller?.removeListener(_onControllerChanged);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ctrl = widget.lifecycle.controller;
    return VisibilityDetector(
      key: const Key('video-visibility'),
      onVisibilityChanged: (info) {
        final vis = info.visibleFraction;
        final c = widget.lifecycle.controller;
        if (c == null) return;
        if (vis < 0.15) {
          c.pause();
        } else if (vis > 0.5 && c.value.isInitialized && !c.value.isPlaying) {
          c.play();
        }
      },
      child: Stack(
        fit: StackFit.expand,
        children: [
          if (ctrl != null && ctrl.value.isInitialized)
            FittedBox(
              fit: BoxFit.cover,
              child: SizedBox(
                width: ctrl.value.size.width,
                height: ctrl.value.size.height,
                child: VideoPlayer(ctrl),
              ),
            ),
          if (_loading)
            const Center(child: CircularProgressIndicator()),
          if (_error)
            _ErrorOverlay(onRetry: () async {
              setState(() => _loading = true);
              await widget.lifecycle.retry();
            }),
        ],
      ),
    );
  }
}

class _ErrorOverlay extends StatelessWidget {
  const _ErrorOverlay({required this.onRetry});
  final VoidCallback onRetry;
  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black.withOpacity(0.35),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Video failed to play', style: TextStyle(fontSize: 16)),
            const SizedBox(height: 12),
            ElevatedButton(onPressed: onRetry, child: const Text('Retry')),
          ],
        ),
      ),
    );
  }
}
