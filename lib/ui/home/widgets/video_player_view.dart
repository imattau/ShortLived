import 'package:flutter/material.dart';
import '../../../state/feed_controller.dart';
import '../../../data/repos/feed_repository.dart';
import '../../../data/models/post.dart';
import 'video_card.dart';

class VideoPlayerView extends StatefulWidget {
  const VideoPlayerView({super.key});

  @override
  State<VideoPlayerView> createState() => _VideoPlayerViewState();
}

class _VideoPlayerViewState extends State<VideoPlayerView> {
  late final FeedController controller;
  final PageController pageController = PageController();

  @override
  void initState() {
    super.initState();
    controller = FeedController(MockFeedRepository());
    controller.addListener(_onController);
    controller.loadInitial();
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

    return PageView.builder(
      controller: pageController,
      scrollDirection: Axis.vertical,
      onPageChanged: controller.onPageChanged,
      itemCount: posts.length,
      itemBuilder: (context, i) {
        final Post p = posts[i];
        final isCurrent = i == controller.index;
        final isNeighbour = controller.preloadCandidates.contains(i);
        return VideoCard(
            post: p, isCurrent: isCurrent, isNeighbour: isNeighbour);
      },
    );
  }
}
