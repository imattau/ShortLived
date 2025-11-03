import 'dart:async';
import 'package:hive_flutter/hive_flutter.dart';

import '../../data/models/author.dart';
import '../../data/models/post.dart';
import 'cache_service.dart';

class CacheServiceHive implements CacheService {
  CacheServiceHive({
    this.maxPosts = 50,
    HiveInterface? hive,
    Future<void> Function(HiveInterface hive)? initializer,
  })  : _hive = hive ?? Hive,
        _initializer = initializer ?? _defaultInitializer;

  static const String _postsBoxName = 'feed_cache_posts';
  static const String _thumbsBoxName = 'feed_cache_thumbs';
  static const String _postsKey = 'posts';

  final int maxPosts;
  final HiveInterface _hive;
  final Future<void> Function(HiveInterface hive) _initializer;

  Future<void>? _ready;
  Box<dynamic>? _postsBox;
  Box<dynamic>? _thumbsBox;
  bool _storageAvailable = false;

  List<Post> _memoryPosts = const [];
  final Map<String, String> _memoryThumbs = {};

  static Future<void> _defaultInitializer(HiveInterface hive) async {
    await Hive.initFlutter();
  }

  @override
  Future<void> init() {
    return _ready ??= _openBoxes();
  }

  Future<void> _openBoxes() async {
    try {
      await _initializer(_hive);
      _postsBox = await _hive.openBox<dynamic>(_postsBoxName);
      _thumbsBox = await _hive.openBox<dynamic>(_thumbsBoxName);
      _storageAvailable = true;
    } catch (_) {
      _storageAvailable = false;
    }
  }

  @override
  Future<void> cacheThumb(String postId, String url) async {
    await init();
    if (_storageAvailable) {
      try {
        await _thumbsBox?.put(postId, url);
        return;
      } catch (_) {
        _storageAvailable = false;
      }
    }
    _memoryThumbs[postId] = url;
  }

  @override
  Future<void> savePosts(List<Post> posts) async {
    await init();
    final limited = posts.take(maxPosts).toList(growable: false);
    final ids = limited.map((p) => p.id).toSet();

    if (_storageAvailable) {
      try {
        final serialized = limited.map(_postToMap).toList(growable: false);
        await _postsBox?.put(_postsKey, serialized);
        await _pruneThumbs(ids);
        return;
      } catch (_) {
        _storageAvailable = false;
      }
    }

    _memoryPosts = limited;
    _pruneMemoryThumbs(ids);
  }

  @override
  Future<List<Post>> loadCachedPosts() async {
    await init();
    if (_storageAvailable) {
      try {
        final raw = _postsBox?.get(_postsKey);
        if (raw is List) {
          final result = <Post>[];
          for (final entry in raw) {
            if (entry is Map) {
              final post = _postFromMap(Map<String, dynamic>.from(entry));
              if (post != null) {
                result.add(post);
              }
            }
          }
          return _applyThumbOverrides(result);
        }
        return const [];
      } catch (_) {
        _storageAvailable = false;
      }
    }
    return _applyThumbOverrides(List<Post>.from(_memoryPosts));
  }

  Future<void> _pruneThumbs(Set<String> keep) async {
    if (!_storageAvailable) return;
    try {
      final keys = _thumbsBox?.keys
              .whereType<String>()
              .where((key) => !keep.contains(key))
              .toList(growable: false) ??
          const <String>[];
      if (keys.isNotEmpty) {
        await _thumbsBox?.deleteAll(keys);
      }
    } catch (_) {
      _storageAvailable = false;
    }
  }

  void _pruneMemoryThumbs(Set<String> keep) {
    final remove = <String>[];
    for (final entry in _memoryThumbs.entries) {
      if (!keep.contains(entry.key)) {
        remove.add(entry.key);
      }
    }
    for (final key in remove) {
      _memoryThumbs.remove(key);
    }
  }

  List<Post> _applyThumbOverrides(List<Post> posts) {
    if (posts.isEmpty) return posts;
    final overrides = <String, String>{};
    if (_storageAvailable) {
      try {
        for (final key in _thumbsBox?.keys.whereType<String>() ?? const <String>[]) {
          final value = _thumbsBox?.get(key);
          if (value is String && value.isNotEmpty) {
            overrides[key] = value;
          }
        }
      } catch (_) {}
    }
    overrides.addAll(_memoryThumbs);
    if (overrides.isEmpty) {
      return posts;
    }
    return posts
        .map((post) {
          final override = overrides[post.id];
          if (override == null || override.isEmpty || override == post.thumb) {
            return post;
          }
          return _replaceThumb(post, override);
        })
        .toList(growable: false);
  }

  Post _replaceThumb(Post post, String thumb) => Post(
        id: post.id,
        author: post.author,
        caption: post.caption,
        tags: post.tags,
        url: post.url,
        thumb: thumb,
        mime: post.mime,
        width: post.width,
        height: post.height,
        duration: post.duration,
        likeCount: post.likeCount,
        commentCount: post.commentCount,
        repostCount: post.repostCount,
        createdAt: post.createdAt,
      );

  static Map<String, dynamic> _postToMap(Post post) => {
        'id': post.id,
        'caption': post.caption,
        'tags': post.tags,
        'url': post.url,
        'thumb': post.thumb,
        'mime': post.mime,
        'width': post.width,
        'height': post.height,
        'duration': post.duration,
        'likeCount': post.likeCount,
        'commentCount': post.commentCount,
        'repostCount': post.repostCount,
        'createdAt': post.createdAt.toIso8601String(),
        'author': {
          'pubkey': post.author.pubkey,
          'name': post.author.name,
          'avatarUrl': post.author.avatarUrl,
          'following': post.author.following,
        },
      };

  static Post? _postFromMap(Map<String, dynamic> map) {
    try {
      final authorMap = map['author'];
      if (authorMap is! Map) return null;
      final createdRaw = map['createdAt'];
      DateTime? created;
      if (createdRaw is String) {
        created = DateTime.tryParse(createdRaw);
      } else if (createdRaw is int) {
        created = DateTime.fromMillisecondsSinceEpoch(createdRaw, isUtc: true);
      }
      if (created == null) return null;
      return Post(
        id: map['id'] as String,
        author: Author(
          pubkey: authorMap['pubkey'] as String? ?? '',
          name: authorMap['name'] as String? ?? '',
          avatarUrl: authorMap['avatarUrl'] as String? ?? '',
          following: authorMap['following'] as bool? ?? false,
        ),
        caption: map['caption'] as String? ?? '',
        tags: (map['tags'] as List?)?.whereType<String>().toList() ?? const [],
        url: map['url'] as String? ?? '',
        thumb: map['thumb'] as String? ?? '',
        mime: map['mime'] as String? ?? '',
        width: map['width'] as int? ?? 0,
        height: map['height'] as int? ?? 0,
        duration: (map['duration'] as num?)?.toDouble() ?? 0.0,
        likeCount: map['likeCount'] as int? ?? 0,
        commentCount: map['commentCount'] as int? ?? 0,
        repostCount: map['repostCount'] as int? ?? 0,
        createdAt: created,
      );
    } catch (_) {
      return null;
    }
  }
}
