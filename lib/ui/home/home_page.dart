import 'package:flutter/material.dart';
import '../design/tokens.dart';
import 'widgets/feed_pager.dart';
import '../../feed/demo_feed.dart';
import '../overlay/hud_overlay.dart';
import '../overlay/hud_model.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late final HudState _hud = HudState(
    visible: ValueNotifier<bool>(true),
    muted: ValueNotifier<bool>(true),
    model: ValueNotifier<HudModel>(HudModel(
      caption: demoFeed[0].caption,
      likeCount: demoFeed[0].likeCount,
      commentCount: demoFeed[0].commentCount,
      repostCount: demoFeed[0].repostCount,
      shareCount: demoFeed[0].shareCount,
      zapCount: demoFeed[0].zapCount,
    )),
  );

  OverlayEntry? _entry;

  @override
  void initState() {
    super.initState();
    // Insert overlay once at startup.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final overlay = Overlay.of(context);
      _entry = OverlayEntry(
        builder: (ctx) => Positioned.fill(
          child: HudOverlay(
            state: _hud,
            onLike: () {},
            onComment: () {},
            onRepost: () {},
            onShare: () {},
            onSave: () {},
            onZap: () {},
          ),
        ),
      );
      overlay.insert(_entry!);
    });
  }

  @override
  void dispose() {
    _entry?.remove();
    _hud.visible.dispose();
    _hud.muted.dispose();
    _hud.model.dispose();
    super.dispose();
  }

  void _onIndexChanged(int i) {
    final f = demoFeed[i];
    _hud.model.value = HudModel(
      caption: f.caption,
      likeCount: f.likeCount,
      commentCount: f.commentCount,
      repostCount: f.repostCount,
      shareCount: f.shareCount,
      zapCount: f.zapCount,
    );
  }

  @override
  Widget build(BuildContext context) {
    // Feed is the only child of Scaffold; overlays live in OverlayEntry above it.
    return Scaffold(
      backgroundColor: T.bg,
      body: ValueListenableBuilder<bool>(
        valueListenable: _hud.muted,
        builder: (_, muted, __) => FeedPager(
          items: demoFeed,
          muted: muted,
          onIndexChanged: _onIndexChanged,
        ),
      ),
    );
  }
}
