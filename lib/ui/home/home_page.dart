import 'package:flutter/material.dart';
import '../design/tokens.dart';
import 'widgets/feed_pager.dart';
import '../../feed/demo_feed.dart';
import '../overlay/hud_overlay.dart';
import '../overlay/hud_model.dart';
import 'feed_controller.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late final FeedController _controller = FeedController();

  late final HudState _hud = HudState(
    visible: ValueNotifier<bool>(true),
    muted: _controller.muted,
    model: ValueNotifier<HudModel>(_modelFromItem(demoFeed[0])),
  );

  OverlayEntry? _entry;

  HudModel _modelFromItem(FeedItem f) => HudModel(
        caption: f.caption,
        likeCount: f.likeCount,
        commentCount: f.commentCount,
        repostCount: f.repostCount,
        shareCount: f.shareCount,
        zapCount: f.zapCount,
      );

  void _onIndexChanged(int i) {
    _hud.model.value = _modelFromItem(demoFeed[i]);
  }

  void _likeCurrent() {
    final i = _controller.index.value;
    final item = demoFeed[i];
    int asInt(String s) => int.tryParse(s.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0;
    var v = asInt(item.likeCount) + 1;
    item.likeCount = v >= 1000 ? '${(v / 1000).toStringAsFixed(1)}k' : '$v';
    _hud.model.value = _modelFromItem(item);
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final overlay = Overlay.of(context);
      _entry = OverlayEntry(
        builder: (ctx) => Positioned.fill(
          child: HudOverlay(
            state: _hud,
            controller: _controller,
            onLikeLogical: _likeCurrent,
          ),
        ),
      );
      overlay.insert(_entry!);
    });
  }

  @override
  void dispose() {
    _entry?.remove();
    _controller.dispose();
    _hud.visible.dispose();
    _hud.model.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: T.bg,
      body: FeedPager(
        items: demoFeed,
        controller: _controller,
        onIndexChanged: _onIndexChanged,
        onDoubleTapLike: (_) => _likeCurrent(),
      ),
    );
  }
}
