import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:video_player/video_player.dart';
import '../../../state/feed_controller.dart';
import '../../../data/repos/feed_repository.dart';
import '../../../data/models/post.dart';
import '../video_controller_pool.dart';
import 'video_card.dart';
import 'package:nostr_video/core/di/locator.dart';
import '../../../core/testing/test_switches.dart';
import '../../../services/nostr/relay_service.dart';
import '../../../services/cache/cache_service.dart';

class VideoPlayerView extends StatefulWidget {
  const VideoPlayerView({super.key, required this.globalPaused});
  final bool globalPaused; // paused by sheet or app lifecycle

  @override
  State<VideoPlayerView> createState() => _VideoPlayerViewState();
}

class _VideoPlayerViewState extends State<VideoPlayerView> with WidgetsBindingObserver {
  late final FeedController controller;
  final PageController pageController = PageController();

  ControllerPool<VideoPlayerController>? pool;
  Timer? _initDebounce;
  Future<void>? _refreshing;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    final relay = Locator.I.get<RelayService>();
    final cache = Locator.I.get<CacheService>();
    controller = FeedController(RealFeedRepository(relay, cache));
    Locator.I.put<FeedController>(controller);
    controller.addListener(_onController);
    controller.connect();

    if (!TestSwitches.disableVideo) {
      pool = ControllerPool<VideoPlayerController>(
        ctor: (url) async {
          final c = VideoPlayerController.networkUrl(Uri.parse(url));
          await c.initialize();
          await c.setLooping(true);
          // Web allows autoplay only when muted.
          await c.setVolume(kIsWeb ? 0.0 : 1.0);
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

  Future<void> _refreshPool() {
    if (TestSwitches.disableVideo) return Future.value();
    final future = _doRefresh();
    _refreshing = future;
    return future;
  }

  Future<void> _doRefresh() async {
    if (!mounted || TestSwitches.disableVideo || pool == null) return;
    final posts = controller.posts;
    if (posts.isEmpty) return;
    final idx = controller.index;
    final keep = <int>{idx};
    if (idx - 1 >= 0) keep.add(idx - 1);
    if (idx + 1 < posts.length) keep.add(idx + 1);

    // Map urls for the keep set only
    final m = <int, String>{for (final i in keep) i: posts[i].url};

    await pool!.ensureFor(indexToUrl: m, keep: keep);

    // Auto play/pause current based on global state is handled in RealVideoView
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _initDebounce?.cancel();
    controller.removeListener(_onController);
    pageController.dispose();
    WidgetsBinding.instance.removeObserver(this);
    _disposeAsync();
    super.dispose();
  }

  Future<void> _disposeAsync() async {
    await _refreshing;
    if (!TestSwitches.disableVideo) {
      await pool?.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    final posts = controller.posts;
    if (posts.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    final useVideo = !TestSwitches.disableVideo && pool != null;

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
            final ctl = useVideo ? pool![i] : null;
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
          right: 8,
          top: 8,
          child: Text(
            useVideo ? '${pool!.size}' : '0',
            key: const Key('active-controllers'),
            style: const TextStyle(fontSize: 10),
          ),
        ),
      ],
    );
  }
}
