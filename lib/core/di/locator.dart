import '../../services/cache/cache_service.dart';
import '../../data/models/post.dart';

class Locator {
  Locator._() {
    final cache = _MemoryCacheService();
    cache.init();
    put<CacheService>(cache);
  }
  static final Locator I = Locator._();

  final Map<Type, dynamic> _store = {};

  void put<T>(T value) => _store[T] = value;
  T get<T>() => _store[T] as T;
  T? tryGet<T>() => _store[T] as T?;
  bool contains<T>() => _store.containsKey(T);
}

class _MemoryCacheService implements CacheService {
  List<Post> _posts = [];

  @override
  Future<void> cacheThumb(String postId, String url) async {}

  @override
  Future<void> init() async {}

  @override
  Future<List<Post>> loadCachedPosts() async => List<Post>.from(_posts);

  @override
  Future<void> savePosts(List<Post> posts) async {
    _posts = List<Post>.from(posts);
  }
}

