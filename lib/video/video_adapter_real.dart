import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:video_player/video_player.dart';
import '../ui/home/widgets/unsupported_overlay.dart';
import 'web_video_compat.dart';
import 'video_adapter.dart';

class RealVideoAdapter extends VideoAdapter {
  @override
  Widget build({
    required String url,
    required bool autoplay,
    required bool muted,
    required BoxFit fit,
    required VideoReady onReady,
    VoidCallback? onSkip,
    void Function(String message)? onUnsupported,
    Key? key,
  }) {
    return _RealVideo(
      key: key,
      url: url,
      autoplay: autoplay,
      muted: muted,
      fit: fit,
      onReady: onReady,
      onSkip: onSkip,
      onUnsupported: onUnsupported,
    );
  }

  @override
  Future<void> warmUp(List<String> urls) async {
    // No-op placeholder; some platforms can preconnect here if desired.
  }
}

class _RealVideo extends StatefulWidget {
  final String url;
  final bool autoplay;
  final bool muted;
  final BoxFit fit;
  final VideoReady onReady;
  final VoidCallback? onSkip;
  final void Function(String message)? onUnsupported;
  const _RealVideo({
    super.key,
    required this.url,
    required this.autoplay,
    required this.muted,
    required this.fit,
    required this.onReady,
    this.onSkip,
    this.onUnsupported,
  });

  @override
  State<_RealVideo> createState() => _RealVideoState();
}

class _RealVideoState extends State<_RealVideo> {
  VideoPlayerController? _c;
  bool _readyCalled = false;
  bool _error = false;

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    final url = widget.url;
    if (!WebVideoCompat.browserCanLikelyPlay(url)) {
      widget.onUnsupported?.call('Codec not supported by this browser');
      setState(() => _error = true);
      return;
    }

    final c = VideoPlayerController.networkUrl(
      Uri.parse(url),
      videoPlayerOptions: VideoPlayerOptions(mixWithOthers: true),
      httpHeaders: const {'accept': '*/*'},
    );
    _c = c;

    try {
      await c.initialize();
      await c.setLooping(true);
      await c.setVolume(widget.muted ? 0.0 : 1.0);
      if (kIsWeb) {
        WebVideoCompat.createWithCors();
      }
      if (widget.autoplay) {
        WidgetsBinding.instance.addPostFrameCallback((_) => c.play());
      }
      if (!_readyCalled) {
        _readyCalled = true;
        widget.onReady();
      }
      setState(() {});
    } catch (e) {
      widget.onUnsupported?.call(e.toString());
      setState(() => _error = true);
    }
  }

  @override
  void didUpdateWidget(covariant _RealVideo oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.muted != widget.muted && _c != null) {
      _c!.setVolume(widget.muted ? 0.0 : 1.0);
    }
  }

  @override
  void dispose() {
    _c?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_c == null || !_c!.value.isInitialized) {
      return const SizedBox.expand();
    }
    final player = FittedBox(
      fit: widget.fit,
      clipBehavior: Clip.hardEdge,
      child: SizedBox(
        width: _c!.value.size.width,
        height: _c!.value.size.height,
        child: VideoPlayer(_c!),
      ),
    );
    if (_error || _c!.value.hasError) {
      return Stack(
        fit: StackFit.expand,
        children: [
          player,
          UnsupportedOverlay(
            message: 'Unsupported or blocked video',
            onSkip: widget.onSkip,
          ),
        ],
      );
    }
    return player;
  }
}
