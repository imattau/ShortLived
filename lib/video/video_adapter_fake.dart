import 'package:flutter/material.dart';
import 'video_adapter.dart';

/// Fake video widget for tests: paints a solid box and calls onReady synchronously.
/// No timers, no async plugin, fully deterministic for widget tests.
class FakeVideoAdapter extends VideoAdapter {
  @override
  Widget build({
    required String url,
    required bool autoplay,
    required bool muted,
    required BoxFit fit,
    required VideoReady onReady,
    Key? key,
  }) {
    return _FakeVideo(key: key, onReady: onReady);
  }
}

class _FakeVideo extends StatelessWidget {
  final VideoReady onReady;
  const _FakeVideo({super.key, required this.onReady});

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) => onReady());
    return const ColoredBox(color: Color(0xFF101010));
  }
}
