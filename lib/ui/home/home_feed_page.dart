import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import "package:shared_preferences/shared_preferences.dart";
import '../../state/overlay_visibility_controller.dart';
import "../../data/repos/feed_repository.dart";
import '../../state/feed_controller.dart';
import 'widgets/overlay_cluster.dart';
import 'widgets/video_card.dart';

final sharedPrefsProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError();
});

final overlayVisibilityControllerProvider = ChangeNotifierProvider<OverlayVisibilityController>((ref) {
  final prefs = ref.watch(sharedPrefsProvider);
  final controller = OverlayVisibilityController(prefs);
  controller.load();
  return controller;
});

final feedRepositoryProvider = Provider<FeedRepository>((ref) => MockFeedRepository());

final feedControllerProvider = StateNotifierProvider<FeedController, FeedState>((ref) {
  final repo = ref.watch(feedRepositoryProvider);
  final controller = FeedController(repo);
  controller.loadInitial();
  return controller;
});

class HomeFeedPage extends ConsumerWidget {
  const HomeFeedPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final overlayVisible = ref.watch(overlayVisibilityControllerProvider).visible;
    final feedState = ref.watch(feedControllerProvider);
    final pageController = PageController();

    return GestureDetector(
      onLongPress: () => ref.read(overlayVisibilityControllerProvider).toggle(),
      onDoubleTap: () {
        // like
      },
      onTap: () {
        // play/pause
      },
      child: Stack(
        children: [
          PageView.builder(
            controller: pageController,
            scrollDirection: Axis.vertical,
            itemCount: feedState.posts.length,
            onPageChanged: (i) => ref.read(feedControllerProvider.notifier).setIndex(i),
            itemBuilder: (context, index) {
              final post = feedState.posts[index];
              return VideoCard(post: post);
            },
          ),
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Container(
              height: 100,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.black54, Colors.transparent],
                ),
              ),
            ),
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              height: 100,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  colors: [Colors.black54, Colors.transparent],
                ),
              ),
            ),
          ),
          AnimatedOpacity(
            opacity: overlayVisible ? 1 : 0,
            duration: const Duration(milliseconds: 200),
            child: AnimatedSlide(
              offset: overlayVisible ? Offset.zero : const Offset(0, 0.1),
              duration: const Duration(milliseconds: 200),
              child: OverlayCluster(
                onCreate: () {
                  showModalBottomSheet(
                    context: context,
                    builder: (_) => const Placeholder(),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
