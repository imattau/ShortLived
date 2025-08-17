import 'dart:async';
import 'package:flutter/material.dart';
import '../design/tokens.dart';
import 'widgets/feed_pager.dart';
import '../../feed/demo_feed.dart';
import '../../feed/data_source.dart';
import '../overlay/hud_overlay.dart';
import '../overlay/hud_model.dart';
import 'feed_controller.dart';
import 'widgets/create_button.dart';
import '../../navigation/route_observer.dart';
import 'package:flutter/services.dart';
import '../../core/config/app_config.dart';
import '../../data/source_selector.dart';
import '../../web/url_shim.dart'
    if (dart.library.html) '../../web/url_shim_web.dart';
import '../../utils/count_format.dart';
import '../../utils/caption_format.dart';
import '../../platform/share/share.dart';
import '../../utils/prefs.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with RouteAware {
  late final FeedController _controller = FeedController();
  late final FeedDataSource _ds = SourceSelector.instance;

  OverlayEntry? _entry;
  StreamSubscription<List<FeedItem>>? _sub;

  // Start with demo only if flag is OFF
  List<FeedItem> _items = AppConfig.nostrEnabled ? <FeedItem>[] : demoFeed;
  int _initialIndex = 0;
  final bool _nostrActive = AppConfig.nostrEnabled; // for UI banner

  bool _showFab = true;

  late final HudState _hud = HudState(
    visible: ValueNotifier<bool>(true),
    muted: _controller.muted,
    model: ValueNotifier<HudModel>(
      AppConfig.nostrEnabled
          ? const HudModel(
              caption: 'Loading Nostr…', fullCaption: 'Loading Nostr…')
          : _modelFromItem(_items[0]),
    ),
  );

  HudModel _modelFromItem(FeedItem f) => HudModel(
        caption: CaptionFormat.display(f.caption),
        fullCaption: f.caption,
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
    VideoPrefs.getMuted().then((m) {
      _controller.muted.value = m;
    });
    _controller.muted.addListener(() {
      VideoPrefs.setMuted(_controller.muted.value);
    });
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
      debugPrint('[ShortLived] Feed delivered ${list.length} items');
      setState(() {
        _items = list;
        if (_items.isEmpty && AppConfig.nostrEnabled) {
          // keep HUD model text but do not flip back to demo
          _hud.model.value = _hud.model.value.copyWith(
            caption:
                'No Nostr videos found yet. Pull to refresh or try another relay.',
            fullCaption:
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

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final route = ModalRoute.of(context);
    if (route != null) {
      routeObserver.subscribe(this, route);
    }
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

  void _snack(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg)),
    );
  }

  void _bumpShareCount(int i) {
    final item = _items[i];
    var v = parseCount(item.shareCount) + 1;
    item.shareCount = formatCount(v);
    _hud.model.value = _modelFromItem(item);
  }

  Future<void> _shareCurrent() async {
    final i = _controller.index.value;
    if (i < 0 || i >= _items.length) return;
    final f = _items[i];

    final url = urlShim.buildUrl({'v': '$i', 'id': f.id});
    final text = f.caption.isEmpty ? 'Watch on ShortLived' : f.caption;

    if (!shareShim.isSupported) {
      await Clipboard.setData(ClipboardData(text: url));
      _snack('Link copied');
      _bumpShareCount(i);
      return;
    }

    final ok = await shareShim.share(
      url: url,
      text: text,
      title: 'ShortLived',
    );
    if (!ok) {
      await Clipboard.setData(ClipboardData(text: url));
      _snack('Link copied');
    }
    _bumpShareCount(i);
  }

  @override
  void dispose() {
    _entry?.remove();
    _controller.dispose();
    _hud.visible.dispose();
    _hud.model.dispose();
    _sub?.cancel();
    _ds.dispose();
    routeObserver.unsubscribe(this);
    super.dispose();
  }

  @override
  void didPushNext() {
    setState(() => _showFab = false);
  }

  @override
  void didPopNext() {
    setState(() => _showFab = true);
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
            onUnsupported: (reason) {
              debugPrint('[ShortLived] Unsupported: '
                  '$reason → skipping');
              _controller.next();
            },
            onSkip: _controller.next,
          );

    return Scaffold(
      backgroundColor: T.bg,
      body: body,
      floatingActionButton: AnimatedSlide(
        duration: const Duration(milliseconds: 180),
        offset: _showFab ? Offset.zero : const Offset(0, 1.5),
        child: AnimatedOpacity(
          duration: const Duration(milliseconds: 180),
          opacity: _showFab ? 1 : 0,
          child: const CreateButton(),
        ),
      ),
      // Center the create button so drawers and rails don't shift it.
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}
