import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:video_player/video_player.dart';
import 'package:http/http.dart' as http;
import '../ui/home/widgets/unsupported_overlay.dart';
import 'web_video_compat.dart';
import 'video_adapter.dart';
import '../core/config/app_config.dart';
import 'source_filter.dart';

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
  bool _disposed = false;

  void _safeSetState(VoidCallback fn) {
    if (!mounted || _disposed) return;
    setState(fn);
  }

  void _onCtrlUpdate() {
    if (!mounted) return;
    _safeSetState(() {});
  }

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    final url = widget.url;
    final uri = Uri.parse(url);
    String? contentType;
    try {
      final resp = await http.head(uri);
      contentType = resp.headers['content-type'];
    } catch (_) {}

    final isHls = WebVideoCompat.isHls(url) ||
        (contentType?.toLowerCase().contains('mpegurl') ?? false);

    if (kIsWeb && isHls && !AppConfig.webHlsPreferred) {
      widget.onUnsupported?.call('HLS disabled by flag');
      _safeSetState(() => _error = true);
      return;
    }
    if (!SourceFilter.allow(contentType: contentType, uri: uri)) {
      widget.onUnsupported?.call('Blocked by type gate: ct=$contentType');
      _safeSetState(() => _error = true);
      return;
    }
    if (!WebVideoCompat.browserCanLikelyPlay(url)) {
      widget.onUnsupported?.call('Codec not supported by this browser');
      _safeSetState(() => _error = true);
      return;
    }

    final local = VideoPlayerController.networkUrl(
      uri,
      videoPlayerOptions: VideoPlayerOptions(mixWithOthers: true),
      httpHeaders: const {'accept': '*/*'},
      formatHint: isHls ? VideoFormat.hls : null,
    );

    try {
      await local.initialize();
      if (!mounted) {
        await local.dispose();
        return;
      }
      await local.setLooping(true);
      if (!mounted) {
        await local.dispose();
        return;
      }

      if (widget.autoplay) {
        await local.setVolume(0.0);
        if (!mounted) {
          await local.dispose();
          return;
        }
        try {
          await local.play();
        } catch (_) {}
        if (!widget.muted) {
          await local.setVolume(1.0);
        }
      } else {
        await local.setVolume(widget.muted ? 0.0 : 1.0);
      }
      if (!mounted) {
        await local.dispose();
        return;
      }

      if (kIsWeb) {
        WebVideoCompat.createWithCors();
      }

      _c?.removeListener(_onCtrlUpdate);
      await _c?.dispose();

      _c = local;
      _c!.addListener(_onCtrlUpdate);

      if (!_readyCalled) {
        _readyCalled = true;
        widget.onReady();
      }
      _safeSetState(() {});
    } catch (e) {
      if (!mounted) {
        await local.dispose();
        return;
      }
      await local.dispose();
      widget.onUnsupported?.call('Video init error: $e');
      _safeSetState(() => _error = true);
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
    _disposed = true;
    _c?.removeListener(_onCtrlUpdate);
    _c?.dispose();
    _c = null;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_c == null || !_c!.value.isInitialized) {
      return const SizedBox.expand();
    }
    Widget player = FittedBox(
      fit: widget.fit,
      clipBehavior: Clip.hardEdge,
      child: SizedBox(
        width: _c!.value.size.width,
        height: _c!.value.size.height,
        child: VideoPlayer(_c!),
      ),
    );
    if (_error || _c!.value.hasError) {
      player = Stack(
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
    if (kIsWeb) {
      player = GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () async {
          if (_c == null) return;
          if (!_c!.value.isPlaying) {
            try {
              await _c!.play();
              if (!widget.muted) {
                await _c!.setVolume(1.0);
              }
            } catch (_) {}
          }
        },
        child: player,
      );
    }
    return player;
  }

}
