import 'package:flutter/widgets.dart';

typedef VideoReady = void Function();

abstract class VideoAdapter {
  /// Build a video widget for [url]. Must call [onReady] exactly once when ready to play/seek.
  Widget build({
    required String url,
    required bool autoplay,
    required bool muted,
    required BoxFit fit,
    required VideoReady onReady,
    VoidCallback? onSkip,
    void Function(String message)? onUnsupported,
    Key? key,
  });

  /// Optional: hint to warm up upcoming videos.
  Future<void> warmUp(List<String> urls) async {}

  /// Cleanup any adapter-wide resources.
  Future<void> dispose() async {}
}

/// Inherited provider for the current adapter.
class VideoScope extends InheritedWidget {
  final VideoAdapter adapter;
  const VideoScope({super.key, required this.adapter, required super.child});

  static VideoAdapter of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<VideoScope>();
    assert(scope != null, 'VideoScope not found in widget tree');
    return scope!.adapter;
  }

  @override
  bool updateShouldNotify(VideoScope oldWidget) => oldWidget.adapter != adapter;
}
