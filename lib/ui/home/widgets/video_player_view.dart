import 'dart:async';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import '../../../state/feed_controller.dart';
import '../../../data/repos/feed_repository.dart';
import '../../../data/models/post.dart';
import '../video_controller_pool.dart';
import 'video_card.dart';
import '../../../core/di/locator.dart';

class VideoPlayerView extends StatefulWidget {
  const VideoPlayerView({super.key, required this.globalPaused});
  final bool globalPaused; // paused by sheet or app lifecycle

  @override
  State<VideoPlayerView> createState() => _VideoPlayerViewState();
}

class _VideoPlayerViewState extends State<VideoPlayerView> with WidgetsBindingObserver {
  late final FeedController controller;
  final PageController pageController = PageController();

  late final ControllerPool<VideoPlayerController> pool;
  Timer? _initDebounce;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    controller = FeedController(MockFeedRepository());
    Locator.I.put<FeedController>(controller);
    controller.addListener(_onController);
    controller.loadInitial();

    pool = ControllerPool<VideoPlayerController>(
      ctor: (url) async {
        final c = VideoPlayerController.networkUrl(Uri.parse(url));
        await c.initialize();
        await c.setLooping(true);
        await c.setVolume(1.0);
        return c;
        },
      dispose: (c) async {
        await c.pause();
        await c.dispose();
      },
    );

    // Warm initial controllers after first data load
    _initDebounce = Timer(const Duration(milliseconds: 100), _refreshPool);
  }

  @override
  void didUpdateWidget(covariant VideoPlayerView oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Pause/resume current on global toggle
    _refreshPool();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // Pause on inactive/paused; resume on resumed (handled via globalPaused wireup by parent if needed)
    if (state == AppLifecycleState.paused || state == AppLifecycleState.inactive) {
      setState(() {}); // cause RealVideoView rebuild with isPlaying=false
    }
  }

  void _onController() {
    if (mounted) setState(() {});
    _refreshPool();
  }

  Future<void> _refreshPool() async {
    if (!mounted) return;
    final posts = controller.posts;
    if (posts.isEmpty) return;
    final idx = controller.index;
    final keep = <int>{idx};
    if (idx - 1 >= 0) keep.add(idx - 1);
    if (idx + 1 < posts.length) keep.add(idx + 1);

    // Map urls for the keep set only
    final m = <int, String>{ for (final i in keep) i : posts[i].url };

    await pool.ensureFor(indexToUrl: m, keep: keep);

    // Auto play/pause current based on global state is handled in RealVideoView
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _initDebounce?.cancel();
    controller.removeListener(_onController);
    pageController.dispose();
    pool.clear();
    WidgetsBinding.instance.removeObserver(this);
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
          },
          itemCount: posts.length,
          itemBuilder: (context, i) {
            final Post p = posts[i];
            final isCurrent = i == controller.index;
            final isNeighbour = controller.preloadCandidates.contains(i);
            final ctl = pool[i];
            return VideoCard(
              post: p,
              isCurrent: isCurrent,
              isNeighbour: isNeighbour,
              controller: ctl,
              globalPaused: widget.globalPaused,
            );
          },
        ),
        // Debug: show active controller count
        Positioned(
          right: 8, top: 8,
          child: Text('${pool.size}', key: const Key('active-controllers'), style: const TextStyle(fontSize: 10)),
        ),
      ],
    );
  }
}
