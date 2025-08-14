import 'dart:async';
import 'package:flutter/widgets.dart';
import 'package:video_player_platform_interface/video_player_platform_interface.dart';

class FakeVideoPlayerPlatform extends VideoPlayerPlatform {
  int _textureCounter = 0;
  final Map<int, StreamController<VideoEvent>> _controllers = {};
  final Map<int, Duration> _positions = {};

  static void register() {
    VideoPlayerPlatform.instance = FakeVideoPlayerPlatform();
  }

  @override
  Future<void> init() async {
    _controllers.clear();
    _positions.clear();
  }

  @override
  Future<int?> create(DataSource dataSource) async {
    final id = _textureCounter++;
    final controller = StreamController<VideoEvent>();
    _controllers[id] = controller;
    _positions[id] = Duration.zero;
    scheduleMicrotask(() {
      controller.add(VideoEvent(
        eventType: VideoEventType.initialized,
        duration: const Duration(seconds: 1),
        size: const Size(100, 100),
      ));
    });
    return id;
  }

  @override
  Stream<VideoEvent> videoEventsFor(int textureId) {
    return _controllers[textureId]!.stream;
  }

  @override
  Future<void> dispose(int textureId) async {
    await _controllers[textureId]?.close();
    _controllers.remove(textureId);
    _positions.remove(textureId);
  }

  @override
  Future<void> setLooping(int textureId, bool looping) async {}

  @override
  Future<void> play(int textureId) async {}

  @override
  Future<void> pause(int textureId) async {}

  @override
  Future<void> setVolume(int textureId, double volume) async {}

  @override
  Future<void> seekTo(int textureId, Duration position) async {
    _positions[textureId] = position;
  }

  @override
  Future<void> setPlaybackSpeed(int textureId, double speed) async {}

  @override
  Future<Duration> getPosition(int textureId) async {
    return _positions[textureId] ?? Duration.zero;
  }

  @override
  Widget buildView(int textureId) {
    return const SizedBox.shrink();
  }

  @override
  Future<void> setMixWithOthers(bool mixWithOthers) async {}
}
