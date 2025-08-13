class Backoff {
  final Duration base;
  final Duration max;
  Backoff({this.base = const Duration(seconds: 1), this.max = const Duration(seconds: 30)});
  Duration at(int attempt) {
    final ms = base.inMilliseconds * (1 << (attempt.clamp(0, 30)));
    return Duration(milliseconds: ms > max.inMilliseconds ? max.inMilliseconds : ms);
  }
}
