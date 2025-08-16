import 'package:flutter/material.dart';
import '../design/tokens.dart';
import 'widgets/feed_pager.dart';
import '../../feed/demo_feed.dart';
import '../overlay/hud_overlay.dart';
import '../overlay/hud_model.dart';
import 'feed_controller.dart';
import 'package:flutter/services.dart';
import '../../web/url_shim.dart'
    if (dart.library.html) '../../web/url_shim_web.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late final FeedController _controller = FeedController();
  late int _initialIndex = 0;

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
        authorDisplay: f.authorDisplay,
        authorNpub: f.authorNpub,
      );

  @override
  void initState() {
    super.initState();

    // Deep link: prefer id, then v
    final uri = urlShim.current();
    final id = uri.queryParameters['id'];
    final v = uri.queryParameters['v'];
    if (id != null) {
      final idx = demoFeed.indexWhere((e) => e.id == id);
      if (idx >= 0) _initialIndex = idx;
    } else if (v != null) {
      final vi = int.tryParse(v);
      if (vi != null && vi >= 0 && vi < demoFeed.length) _initialIndex = vi;
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final overlay = Overlay.of(context);
      _entry = OverlayEntry(
        builder: (ctx) => Positioned.fill(
          child: HudOverlay(
            state: _hud,
            controller: _controller,
            onLikeLogical: _likeCurrent,
            onCopyLink: _copyLinkCurrent,
          ),
        ),
      );
      overlay.insert(_entry!);

      // Update HUD to selected
      _onIndexChanged(_initialIndex);
      // Push query for initial page so URL is canonical
      _updateUrlForIndex(_initialIndex);
    });
  }

  void _updateUrlForIndex(int i) {
    final f = demoFeed[i];
    urlShim.replaceQuery({'v': '$i', 'id': f.id});
  }

  void _copyLinkCurrent() async {
    final f = demoFeed[_controller.index.value];
    final url = urlShim.buildUrl({
      'v': '${_controller.index.value}',
      'id': f.id,
    });
    await Clipboard.setData(ClipboardData(text: url));
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Link copied')));
  }

  void _onIndexChanged(int i) {
    final f = demoFeed[i];
    _hud.model.value = _modelFromItem(f);
    _controller.index.value = i;
    _updateUrlForIndex(i);
  }

  void _likeCurrent() {
    final i = _controller.index.value;
    final item = demoFeed[i];
    int asInt(String s) =>
        int.tryParse(s.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0;
    var v = asInt(item.likeCount) + 1;
    item.likeCount = v >= 1000 ? '${(v / 1000).toStringAsFixed(1)}k' : '$v';
    _hud.model.value = _modelFromItem(item);
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
        initialIndex: _initialIndex,
      ),
    );
  }
}
