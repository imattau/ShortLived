import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/models/post.dart';
import '../data/repos/feed_repository.dart';

class FeedState {
  final List<Post> posts;
  final int index;
  const FeedState({this.posts = const [], this.index = 0});

  FeedState copyWith({List<Post>? posts, int? index}) => FeedState(
        posts: posts ?? this.posts,
        index: index ?? this.index,
      );
}

class FeedController extends StateNotifier<FeedState> {
  FeedController(this._repo) : super(const FeedState());
  final FeedRepository _repo;

  Future<void> loadInitial() async {
    final posts = await _repo.fetchInitial();
    state = state.copyWith(posts: posts);
  }

  void setIndex(int index) {
    state = state.copyWith(index: index);
  }
}
