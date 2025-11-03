import 'package:flutter/foundation.dart';
import '../data/models/post.dart';
import '../data/repos/feed_repository.dart';
import '../services/nostr/relay_service.dart';
import '../services/queue/action_queue.dart';
import 'dart:async';

/// Minimal controller. Replace with Riverpod later if desired.
class FeedController extends ChangeNotifier {
  final FeedRepository repo;
  FeedController(this.repo);

  final List<Post> _posts = [];
  int _index = 0;
  Set<String> _muted = {};
  bool _online = true;
  ActionQueue? _queue;
  RelayService? _relayForReplay;
  final Set<String> _sessionLiked = {};

  void applyOptimisticPost(Post p) {
    _posts.insert(0, p);
    _index = 0;
    notifyListeners();
  }

  @Deprecated('Use applyOptimisticPost instead')
  void insertOptimistic(Post p) => applyOptimisticPost(p);

  bool incrementCommentCount(String postId) => _adjustCommentCount(postId, 1);

  bool decrementCommentCount(String postId) => _adjustCommentCount(postId, -1);

  bool _adjustCommentCount(String postId, int delta) {
    final idx = _posts.indexWhere((p) => p.id == postId);
    if (idx < 0) return false;
    final original = _posts[idx];
    final next = original.commentCount + delta;
    final safeCount = next < 0 ? 0 : next;
    _posts[idx] = original.copyWith(commentCount: safeCount);
    notifyListeners();
    return true;
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

  StreamSubscription<List<Post>>? _sub;

  Future<void> connect() async {
    final initial = await repo.fetchInitial();
    setPosts(initial);
    _sub?.cancel();
    _sub = repo.watchFeed().listen((list) {
      setPosts(list);
    });
  }

  void setPosts(List<Post> data) {
    String? currentId;
    if (_posts.isNotEmpty && _index < _posts.length) {
      currentId = _posts[_index].id;
    }
    _posts
      ..clear()
      ..addAll(data);
    if (currentId != null) {
      final i = _posts.indexWhere((p) => p.id == currentId);
      _index = i >= 0 ? i : 0;
    } else {
      _index = 0;
    }
    _filterMuted();
  }

  void onPageChanged(int i) {
    if (i == _index) return;
    _index = i;
    notifyListeners();
  }

  /// Force listeners to rebuild after external mutations.
  void refresh() => notifyListeners();

  void bindQueue(ActionQueue q) {
    _queue = q;
  }

  void setOnline(bool v, {RelayService? relay}) {
    _online = v;
    _relayForReplay = relay ?? _relayForReplay;
  }

  Future<bool> likeCurrent(RelayService relay) async {
    if (_posts.isEmpty) return false;
    final p = _posts[_index];
    if (_sessionLiked.contains(p.id)) return true;

    _sessionLiked.add(p.id);
    final before = p.likeCount;
    _posts[_index] = p.copyWith(likeCount: p.likeCount + 1);
    notifyListeners();

    Future<void> doPublish() =>
        relay.like(eventId: p.id, authorPubkey: p.author.pubkey);
    final action = QueuedAction(
        ActionType.like, {'eventId': p.id, 'authorPubkey': p.author.pubkey});

    if (!_online || _queue == null) {
      try {
        await doPublish();
        return true;
      } catch (_) {
        _posts[_index] = p.copyWith(likeCount: before);
        _sessionLiked.remove(p.id);
        notifyListeners();
        return false;
      }
    }

    try {
      await doPublish();
      return true;
    } catch (_) {
      try {
        await _queue!.enqueue(action);
        return true;
      } catch (_) {
        _posts[_index] = p.copyWith(likeCount: before);
        _sessionLiked.remove(p.id);
        notifyListeners();
        return false;
      }
    }
  }

  Post? get currentOrNull => (_posts.isEmpty) ? null : _posts[_index];

  Future<void> repostCurrent(RelayService relay) async {
    if (_posts.isEmpty) return;
    final p = _posts[_index];
    _posts[_index] = p.copyWith(repostCount: p.repostCount + 1);
    notifyListeners();
    try {
      await relay.repost(eventId: p.id);
    } catch (_) {
      // swallow; offline queue could be added later for reposts, but keep UI optimistic
    }
  }

  void setMuted(Set<String> muted) {
    _muted = muted;
    _filterMuted();
  }

  Future<void> enqueuePublish(Map<String, dynamic> eventJson) async {
    if (_queue == null) return;
    await _queue!.enqueue(QueuedAction(ActionType.publish, {'event': eventJson}));
  }

  Future<void> enqueueReply(String parentId, String content,
      {String? parentPubkey, String? rootId, String? rootPubkey}) async {
    if (_queue == null) return;
    await _queue!.enqueue(QueuedAction(ActionType.reply, {
      'parentId': parentId,
      'content': content,
      'parentPubkey': parentPubkey ?? '',
      'rootId': rootId,
      'rootPubkey': rootPubkey,
    }));
  }

  Future<void> enqueueQuote(String eventId, String content) async {
    if (_queue == null) return;
    await _queue!.enqueue(QueuedAction(ActionType.quote, {
      'eventId': eventId,
      'content': content,
    }));
  }

  Future<void> replayQueue(RelayService relay) async {
    if (_queue == null) return;
    final items = await _queue!.all();
    int processed = 0;
    for (final a in items) {
      try {
        switch (a.type) {
          case ActionType.publish:
            final e = Map<String, dynamic>.from(a.payload['event'] as Map);
            final kind = e['kind'] as int;
            final content = (e['content'] as String?) ?? '';
            final tags = (e['tags'] as List?)
                    ?.whereType<List>()
                    .map((t) => t.map((v) => v.toString()).toList())
                    .toList() ??
                <List<String>>[];
            await relay.signAndPublish(kind: kind, content: content, tags: tags);
            break;
          case ActionType.like:
            await relay.like(
              eventId: a.payload['eventId'] as String,
              authorPubkey: a.payload['authorPubkey'] as String,
            );
            break;
          case ActionType.reply:
            await relay.reply(
              parentId: a.payload['parentId'] as String,
              content: a.payload['content'] as String,
              parentPubkey: (a.payload['parentPubkey'] as String).isEmpty
                  ? null
                  : a.payload['parentPubkey'] as String,
              rootId: a.payload['rootId'] as String?,
              rootPubkey: a.payload['rootPubkey'] as String?,
            );
            break;
          case ActionType.quote:
            await relay.quote(
              eventId: a.payload['eventId'] as String,
              content: a.payload['content'] as String,
            );
            break;
        }
        processed++;
      } catch (_) {
        break;
      }
    }
    if (processed > 0) {
      await _queue!.removeFirstN(processed);
    }
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

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }
}
