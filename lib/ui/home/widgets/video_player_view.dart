import 'package:flutter/material.dart';
import '../../../state/feed_controller.dart';
import '../../../data/repos/feed_repository.dart';
import '../../../data/models/post.dart';
import 'video_card.dart';
import '../../../core/di/locator.dart';

class VideoPlayerView extends StatefulWidget {
  const VideoPlayerView({super.key});

  @override
  State<VideoPlayerView> createState() => _VideoPlayerViewState();
}

class _VideoPlayerViewState extends State<VideoPlayerView> {
  late final FeedController controller;
  final PageController pageController = PageController();
  final Set<int> _active = <int>{}; // simulate active video controllers
  int get _current => controller.index;

  @override
  void initState() {
    super.initState();
    controller = FeedController(MockFeedRepository());
    Locator.I.put<FeedController>(controller);
    controller.addListener(() {
      _refreshActive();
      _onController();
    });
    controller.loadInitial().then((_) => _refreshActive());
  }

  void _refreshActive() {
    final desired = <int>{};
    if (controller.posts.isNotEmpty) {
      desired.add(_current);
      if (_current - 1 >= 0) desired.add(_current - 1);
      if (_current + 1 < controller.posts.length) desired.add(_current + 1);
    }
    _active
      ..removeWhere((i) => !desired.contains(i))
      ..addAll(desired);
    if (mounted) setState(() {});
  }

  void _onController() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    controller.removeListener(_onController);
    pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final posts = controller.posts;
    if (posts.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    return Stack(
      fit: StackFit.expand,
      children: [
        PageView.builder(
          key: const Key('feed-pageview'),
          controller: pageController,
          scrollDirection: Axis.vertical,
          onPageChanged: (i) {
            controller.onPageChanged(i);
            _refreshActive();
          },
          itemCount: posts.length,
          itemBuilder: (context, i) {
            final Post p = posts[i];
            final isCurrent = i == controller.index;
            final isNeighbour = controller.preloadCandidates.contains(i);
            return VideoCard(post: p, isCurrent: isCurrent, isNeighbour: isNeighbour);
          },
        ),
        Positioned(
          right: 8,
          top: 8,
          child: Text('${_active.length}',
              key: const Key('active-controllers'),
              style: const TextStyle(fontSize: 10)),
        ),
      ],
    );
  }
}
