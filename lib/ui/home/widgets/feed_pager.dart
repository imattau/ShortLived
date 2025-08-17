import 'package:flutter/material.dart';
import '../../../video/video_adapter.dart';
import '../../../feed/demo_feed.dart';
import '../feed_controller.dart';
import 'video_player_view.dart';

typedef OnIndexChanged = void Function(int index);

class FeedPager extends StatefulWidget {
  final List<FeedItem> items;
  final OnIndexChanged onIndexChanged;
  final FeedController controller;
  final void Function(int index)? onDoubleTapLike;
  final int initialIndex;
  final void Function(String reason)? onUnsupported;
  final VoidCallback? onSkip;

  const FeedPager({
    super.key,
    required this.items,
    required this.onIndexChanged,
    required this.controller,
    this.onDoubleTapLike,
    this.initialIndex = 0,
    this.onUnsupported,
    this.onSkip,
  });

  @override
  State<FeedPager> createState() => _FeedPagerState();
}

class _FeedPagerState extends State<FeedPager> {
  late final PageController _controller = PageController(
    initialPage: widget.initialIndex,
  );
  late int _index = widget.initialIndex;
  bool _didWarmUp = false;

  @override
  void initState() {
    super.initState();
    widget.controller.attach(_controller);
    widget.controller.index.addListener(() {
      // external programmatic moves (not used yet)
    });
    widget.controller.muted.addListener(() {
      setState(() {});
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_didWarmUp) {
      _didWarmUp = true;
      _warmUp(_index);
    }
  }

  void _warmUp(int i) {
    final adapter = VideoScope.of(context);
    final urls = <String>[];
    if (i + 1 < widget.items.length) urls.add(widget.items[i + 1].url);
    if (i - 1 >= 0) urls.add(widget.items[i - 1].url);
    adapter.warmUp(urls);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PageView.builder(
      key: const Key('feed-pageview'),
      controller: _controller,
      scrollDirection: Axis.vertical,
      onPageChanged: (i) {
        setState(() => _index = i);
        widget.controller.index.value = i;
        widget.onIndexChanged(i);
        _warmUp(i);
      },
      itemCount: widget.items.length,
      itemBuilder: (context, i) {
        final item = widget.items[i];
        final isCurrent = i == _index;
        return GestureDetector(
          onDoubleTap: isCurrent && widget.onDoubleTapLike != null
              ? () => widget.onDoubleTapLike!.call(i)
              : null,
          child: _FeedPage(
            key: ValueKey('feed_$i'),
            item: item,
            autoplay: isCurrent,
            muted: widget.controller.muted.value,
            onUnsupported: widget.onUnsupported,
            onSkip: widget.onSkip,
          ),
        );
      },
    );
  }
}

class _FeedPage extends StatefulWidget {
  final FeedItem item;
  final bool autoplay;
  final bool muted;
  final void Function(String reason)? onUnsupported;
  final VoidCallback? onSkip;
  const _FeedPage({
    super.key,
    required this.item,
    required this.autoplay,
    required this.muted,
    this.onUnsupported,
    this.onSkip,
  });

  @override
  State<_FeedPage> createState() => _FeedPageState();
}

class _FeedPageState extends State<_FeedPage>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => false;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return SizedBox.expand(
      child: VideoPlayerView(
        url: widget.item.url,
        autoplay: widget.autoplay,
        muted: widget.muted,
        fit: BoxFit.cover,
        onReady: () {},
        onUnsupported: widget.onUnsupported,
        onSkip: widget.onSkip,
      ),
    );
  }
}
