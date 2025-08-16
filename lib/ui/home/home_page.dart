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
import '../../utils/count_format.dart';
import '../../platform/share_shim.dart'
    if (dart.library.html) '../../platform/share_shim_web.dart';

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

  // Start with demo only if flag is OFF
  List<FeedItem> _items = kNostrEnabled ? <FeedItem>[] : demoFeed;
  int _initialIndex = 0;
  final bool _nostrActive = kNostrEnabled; // for UI banner

  late final HudState _hud = HudState(
    visible: ValueNotifier<bool>(true),
    muted: _controller.muted,
    model: ValueNotifier<HudModel>(
      kNostrEnabled
          ? const HudModel(caption: 'Loading Nostr…')
          : _modelFromItem(_items[0]),
    ),
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
    if (kNostrEnabled) {
      debugPrint(
        '[ShortLived] Data source: NOSTR (relays=${kDefaultRelays.length})',
      );
    } else {
      debugPrint('[ShortLived] Data source: DEMO');
    }

    // Deep link (v/id) against current list (will re-map after data arrives)
    final uri = urlShim.current();
    final id = uri.queryParameters['id'];
    final v = int.tryParse(uri.queryParameters['v'] ?? '');
    if (_items.isNotEmpty) {
      if (v != null && v >= 0 && v < _items.length) _initialIndex = v;
      if (id != null) {
        final idx = _items.indexWhere((e) => e.id == id);
        if (idx >= 0) _initialIndex = idx;
      }
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final overlay = Overlay.of(context);
      _entry = OverlayEntry(
        builder: (ctx) => Positioned.fill(
          child: HudOverlay(
            state: _hud,
            controller: _controller,
            onLikeLogical: _likeCurrent,
            onShareLogical: _shareCurrent,
          ),
        ),
      );
      overlay.insert(_entry!);
    });

    // Subscribe to data source
    _sub = _ds.streamInitial().listen((list) {
      debugPrint('[ShortLived] Nostr delivered ${list.length} items');
      setState(() {
        _items = list;
        if (_items.isEmpty) {
          // keep HUD model text but do not flip back to demo
          _hud.model.value = _hud.model.value.copyWith(
            caption:
                'No Nostr videos found yet. Pull to refresh or try another relay.',
          );
          _initialIndex = 0;
        } else {
          // re-derive initial index by id if present
          final uri = urlShim.current();
          final idParam = uri.queryParameters['id'];
          if (idParam != null) {
            final idx = _items.indexWhere((e) => e.id == idParam);
            if (idx >= 0) _initialIndex = idx;
          } else if (_initialIndex >= _items.length) {
            _initialIndex = 0;
          }
          _hud.model.value = _modelFromItem(_items[_initialIndex]);
        }
      });
    });
  }

  void _updateUrlForIndex(int i) {
    final f = _items[i];
    urlShim.replaceQuery({'v': '$i', 'id': f.id});
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
    var v = parseCount(item.likeCount) + 1;
    item.likeCount = formatCount(v);
    _hud.model.value = _modelFromItem(item);
  }

  Future<void> _shareCurrent() async {
    final i = _controller.index.value;
    if (i < 0 || i >= _items.length) return;
    final f = _items[i];

    final url = urlShim.buildUrl({'v': '$i', 'id': f.id});
    final text = f.caption.isEmpty ? 'Watch on ShortLived' : f.caption;

    bool ok = await shareShim.share(url: url, text: text, title: 'ShortLived');
    if (!ok) {
      await Clipboard.setData(ClipboardData(text: url));
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Link copied')),
        );
      }
      ok = true; // still count as a "share" when copied
    }

    if (ok) {
      var v = parseCount(f.shareCount) + 1;
      f.shareCount = formatCount(v);
      _hud.model.value = _modelFromItem(f);
    }
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
    final body = _items.isEmpty && _nostrActive
        ? Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Text(
                'Loading Nostr… If this persists, check your relays in app_config.dart.',
                style: Theme.of(
                  context,
                ).textTheme.bodyMedium?.copyWith(color: Colors.white70),
                textAlign: TextAlign.center,
              ),
            ),
          )
        : FeedPager(
            items: _items,
            controller: _controller,
            onIndexChanged: _onIndexChanged,
            onDoubleTapLike: (_) => _likeCurrent(),
            initialIndex: _initialIndex,
          );

    return Scaffold(backgroundColor: T.bg, body: body);
  }
}
