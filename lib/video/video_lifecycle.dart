import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:video_player/video_player.dart';

class VideoLifecycle {
  VideoPlayerController? _current;
  VideoPlayerController? _next;
  Uri? _currentUri;
  bool _disposed = false;

  VideoPlayerController? get controller => _current;
  Uri? get uri => _currentUri;

  Future<void> init(Uri uri, {bool muted = true}) async {
    await _swapTo(await _create(uri, muted: muted));
  }

  Future<void> prefetch(Uri uri, {bool muted = true}) async {
    _next?.dispose();
    _next = await _create(uri, muted: muted);
  }

  Future<void> advanceToPrefetched() async {
    if (_next == null) return;
    await _swapTo(_next!);
    _next = null;
  }

  Future<void> retry({bool muted = true}) async {
    if (_currentUri == null) return;
    await _swapTo(await _create(_currentUri!, muted: muted));
  }

  Future<void> setMuted(bool muted) async {
    final c = _current;
    if (c == null) return;
    await c.setVolume(muted ? 0.0 : 1.0);
  }

  Future<void> dispose() async {
    _disposed = true;
    await _current?.dispose();
    await _next?.dispose();
    _current = null;
    _next = null;
  }

  Future<VideoPlayerController> _create(Uri uri, {required bool muted}) async {
    final c = VideoPlayerController.networkUrl(uri);
    await c.initialize();
    await c.setLooping(true);
    await c.setVolume(muted ? 0.0 : 1.0);
    // On web, kick playback muted first to satisfy autoplay policies.
    await c.play();
    return c;
  }

  Future<void> _swapTo(VideoPlayerController next) async {
    if (_disposed) {
      await next.dispose();
      return;
    }
    final old = _current;
    _current = next;
    _currentUri = next.dataSourceUri;
    if (old != null) {
      unawaited(old.dispose());
    }
  }
}
