import 'package:flutter/foundation.dart';
import '../data/models/post.dart';
import '../data/repos/feed_repository.dart';
import '../services/nostr/relay_service.dart';
import 'dart:async';

/// Minimal controller. Replace with Riverpod later if desired.
class FeedController extends ChangeNotifier {
  final FeedRepository repo;
  FeedController(this.repo);

  final List<Post> _posts = [];
  int _index = 0;
  Set<String> _muted = {};
  void insertOptimistic(Post p) {
    _posts.insert(0, p);
    _index = 0;
    notifyListeners();
  }

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
    _filterMuted();
    notifyListeners();
  }

  void onPageChanged(int i) {
    if (i == _index) return;
    _index = i;
    notifyListeners();
  }

  Future<void> likeCurrent(RelayService relay) async {
    if (_posts.isEmpty) return;
    final p = _posts[_index];
    _posts[_index] = Post(
      id: p.id,
      author: p.author,
      caption: p.caption,
      tags: p.tags,
      url: p.url,
      thumb: p.thumb,
      mime: p.mime,
      width: p.width,
      height: p.height,
      duration: p.duration,
      likeCount: p.likeCount + 1,
      commentCount: p.commentCount,
      createdAt: p.createdAt,
    );
    notifyListeners();
    unawaited(relay.like(eventId: p.id));
  }

  void setMuted(Set<String> muted) {
    _muted = muted;
    _filterMuted();
  }

  void _filterMuted() {
    if (_posts.isEmpty) {
      notifyListeners();
      return;
    }
    final keep = _posts
        .where((p) => !_muted.contains(p.author.pubkey))
        .toList();
    _posts
      ..clear()
      ..addAll(keep);
    if (_index >= _posts.length) {
      _index = _posts.isEmpty ? 0 : _posts.length - 1;
    }
    notifyListeners();
  }
}
