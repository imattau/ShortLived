import 'dart:async';
import 'package:flutter/material.dart';
import '../design/tokens.dart';
import 'widgets/feed_pager.dart';
import '../../feed/demo_feed.dart';
import '../../feed/data_source.dart';
import '../overlay/hud_overlay.dart';
import '../overlay/hud_model.dart';
import 'feed_controller.dart';
import 'package:flutter/services.dart';
import '../../config/app_config.dart';
import '../../web/url_shim.dart'
    if (dart.library.html) '../../web/url_shim_web.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late final FeedController _controller = FeedController();
  late final FeedDataSource _ds =
      kNostrEnabled ? NostrFeedDataSource() : DemoFeedDataSource();

  OverlayEntry? _entry;
  StreamSubscription<List<FeedItem>>? _sub;

  // start with demo to render immediately; replace once data arrives
  List<FeedItem> _items = demoFeed;
  int _initialIndex = 0;

  late final HudState _hud = HudState(
    visible: ValueNotifier<bool>(true),
    muted: _controller.muted,
    model: ValueNotifier<HudModel>(_modelFromItem(_items[0])),
  );

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

    // Deep link (v/id) against current list (will re-map after data arrives)
    final uri = urlShim.current();
    final id = uri.queryParameters['id'];
    final v = int.tryParse(uri.queryParameters['v'] ?? '');
    if (v != null && v >= 0 && v < _items.length) _initialIndex = v;
    if (id != null) {
      final idx = _items.indexWhere((e) => e.id == id);
      if (idx >= 0) _initialIndex = idx;
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
    });

    // Subscribe to data source (will replace demo list once available)
    _sub = _ds.streamInitial().listen((list) {
      if (list.isNotEmpty) {
        setState(() {
          _items = list;
          // re-derive initial index by id if present
          final idParam = uri.queryParameters['id'];
          if (idParam != null) {
            final idx = _items.indexWhere((e) => e.id == idParam);
            if (idx >= 0) {
              _initialIndex = idx;
            }
          } else if (_initialIndex >= _items.length) {
            _initialIndex = 0;
          }
          _hud.model.value = _modelFromItem(_items[_initialIndex]);
        });
      }
    });
  }

  void _updateUrlForIndex(int i) {
    final f = _items[i];
    urlShim.replaceQuery({'v': '$i', 'id': f.id});
  }

  void _copyLinkCurrent() async {
    final f = _items[_controller.index.value];
    final url = urlShim.buildUrl({
      'v': '${_controller.index.value}',
      'id': f.id,
    });
    await Clipboard.setData(ClipboardData(text: url));
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Link copied')),
    );
  }

  void _onIndexChanged(int i) {
    final f = _items[i];
    _hud.model.value = _modelFromItem(f);
    _controller.index.value = i;
    _updateUrlForIndex(i);
  }

  void _likeCurrent() {
    final i = _controller.index.value;
    if (i < 0 || i >= _items.length) return;
    final item = _items[i];
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
    _sub?.cancel();
    _ds.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: T.bg,
      body: FeedPager(
        items: _items,
        controller: _controller,
        onIndexChanged: _onIndexChanged,
        onDoubleTapLike: (_) => _likeCurrent(),
        initialIndex: _initialIndex,
      ),
    );
  }
}
