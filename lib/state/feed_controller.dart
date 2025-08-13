import 'package:flutter/foundation.dart';
import '../data/models/post.dart';
import '../data/repos/feed_repository.dart';

/// Minimal controller. Replace with Riverpod later if desired.
class FeedController extends ChangeNotifier {
  final FeedRepository repo;
  FeedController(this.repo);

  final List<Post> _posts = [];
  int _index = 0;

  List<Post> get posts => List.unmodifiable(_posts);
  int get index => _index;

  /// For tests and UI hints: indices we want to preload (±1)
  Set<int> get preloadCandidates {
    final s = <int>{};
    if (_posts.isEmpty) return s;
    if (_index - 1 >= 0) s.add(_index - 1);
    if (_index + 1 < _posts.length) s.add(_index + 1);
    return s;
  }

  Future<void> loadInitial() async {
    final data = await repo.fetchInitial();
    _posts
      ..clear()
      ..addAll(data);
    _index = 0;
    notifyListeners();
  }

  void onPageChanged(int i) {
    if (i == _index) return;
    _index = i;
    notifyListeners();
  }
}
