import '../../data/models/post.dart';

abstract class CacheService {
  Future<void> init();
  Future<void> cacheThumb(String postId, String url);
  Future<void> savePosts(List<Post> posts);
  Future<List<Post>> loadCachedPosts();
}
