typedef Ctor<T> = Future<T> Function(String url);
typedef Disposer<T> = Future<void> Function(T controller);
typedef Player<T> = Future<void> Function(T controller, {required bool play});

/// Generic, testable pool that keeps controllers for `keep` indices only.
class ControllerPool<T> {
  final Ctor<T> ctor;
  final Disposer<T> dispose;
  final Map<int, T> _map = {};

  ControllerPool({required this.ctor, required this.dispose});

  Future<Map<int, T>> ensureFor({
    required Map<int, String> indexToUrl,
    required Set<int> keep,
  }) async {
    // Dispose controllers we no longer want
    final toDispose = _map.keys.where((k) => !keep.contains(k)).toList();
    for (final k in toDispose) {
      await dispose(_map[k] as T);
      _map.remove(k);
    }
    // Ensure we have controllers for desired indices
    for (final k in keep) {
      if (!_map.containsKey(k)) {
        final url = indexToUrl[k];
        if (url == null) continue;
        _map[k] = await ctor(url);
      }
    }
    return Map<int, T>.unmodifiable(_map);
  }

  int get size => _map.length;

  T? operator [](int i) => _map[i];

  Future<void> clear() async {
    // Take a snapshot to avoid concurrent modification if ensureFor is active
    final values = _map.values.toList();
    _map.clear();
    for (final controller in values) {
      await dispose(controller);
    }
  }
}
