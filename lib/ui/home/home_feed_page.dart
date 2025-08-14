import 'package:flutter/material.dart';
import 'widgets/video_player_view.dart';
import 'widgets/overlay_cluster.dart';
import '../sheets/create_sheet.dart';
import '../sheets/comments_sheet.dart';
import '../sheets/zap_sheet.dart';
import '../sheets/profile_sheet.dart';
import '../sheets/details_sheet.dart';
import '../sheets/relays_sheet.dart';
import '../sheets/quote_sheet.dart';
import 'package:nostr_video/core/di/locator.dart';
import '../../core/config/network.dart';
import '../../services/nostr/relay_service_ws.dart';
import '../../services/nostr/relay_service.dart';
import '../../services/lightning/lightning_service_lnurl.dart';
import '../../services/settings/settings_service.dart';
import '../../state/feed_controller.dart';
import '../../data/models/post.dart';
import '../../services/queue/action_queue.dart';
import '../../services/queue/action_queue_hive.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../services/keys/key_service.dart';
import '../../services/keys/key_service_secure.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import '../../core/testing/test_switches.dart';

class HomeFeedPage extends StatefulWidget {
  const HomeFeedPage({super.key});
  @override
  State<HomeFeedPage> createState() => _HomeFeedPageState();
}

class _HomeFeedPageState extends State<HomeFeedPage> with WidgetsBindingObserver {
  bool overlaysVisible = true;
  final ValueNotifier<bool> _pausedBySheet = ValueNotifier(false);
  late final RelayService relay;
  late final LightningServiceLnurl lightning;
  late SettingsService settings;
  late ActionQueue queue;

  Future<void> _openCreate() async {
    _pausedBySheet.value = true;
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.black,
      builder: (ctx) => CreateSheet(onCreated: (post) {
        Locator.I.get<FeedController>().insertOptimistic(post);
      }),
    );
    _pausedBySheet.value = false;
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    if (Locator.I.tryGet<KeyService>() == null) {
      Locator.I.put<KeyService>(KeyServiceSecure(const FlutterSecureStorage()));
    }
    relay = Locator.I.tryGet<RelayService>() ??
        RelayServiceWs(factory: (uri) => WebSocketChannel.connect(uri), keyService: Locator.I.get<KeyService>());
    if (!TestSwitches.disableRelays && !Locator.I.contains<RelayService>()) {
      relay.init(NetworkConfig.relays);
      Locator.I.put<RelayService>(relay);
    }
    lightning = Locator.I.tryGet<LightningServiceLnurl>() ?? LightningServiceLnurl(relay);
    queue = Locator.I.tryGet<ActionQueue>() ?? ActionQueueHive();
    if (!Locator.I.contains<ActionQueue>()) {
      queue.init();
      Locator.I.put<ActionQueue>(queue);
    }
    if (!TestSwitches.disableRelays) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          final c = Locator.I.get<FeedController>();
          c.bindQueue(queue);
          c.setOnline(true, relay: Locator.I.get<RelayService>());
        }
      });
    }
    final existing = Locator.I.tryGet<SettingsService>();
    if (existing != null) {
      settings = existing;
      overlaysVisible = !settings.overlaysDefaultHidden();
    } else {
      SharedPreferences.getInstance().then((sp) {
        settings = SettingsService(sp);
        Locator.I.put<SettingsService>(settings);
        Locator.I.get<FeedController>().setMuted(settings.muted());
        if (mounted) {
          setState(() {
            overlaysVisible = !settings.overlaysDefaultHidden();
          });
        }
      });
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      Locator.I.get<FeedController>().replayQueue(relay);
    }
  }

  Post? get _currentPost {
    final c = Locator.I.get<FeedController>();
    if (c.posts.isEmpty) return null;
    return c.posts[c.index];
  }

  void _like() {
    final controller = Locator.I.get<FeedController>();
    controller.likeCurrent(relay);
  }

  void _repost() {
    final c = Locator.I.get<FeedController>();
    final r = Locator.I.get<RelayService>();
    c.repostCurrent(r);
  }

  Future<void> _openQuote() async {
    final c = Locator.I.get<FeedController>();
    final p = c.currentOrNull;
    if (p == null) return;
    await showModalBottomSheet(
      context: context,
      backgroundColor: Colors.black,
      isScrollControlled: true,
      builder: (_) => QuoteSheet(eventId: p.id, relay: Locator.I.get<RelayService>()),
    );
  }

  Future<void> _comment() async {
    final controller = Locator.I.get<FeedController>();
    if (controller.posts.isEmpty) return;
    final p = controller.posts[controller.index];
    _pausedBySheet.value = true;
    await showModalBottomSheet(
      context: context,
      backgroundColor: Colors.black,
      builder: (_) => CommentsSheet(
        parentEventId: p.id,
        parentPubkey: p.author.pubkey,
        relay: relay,
      ),
    );
    _pausedBySheet.value = false;
  }

  Future<void> _openRelays() async {
    _pausedBySheet.value = true;
    await showModalBottomSheet(
      context: context,
      backgroundColor: Colors.black,
      isScrollControlled: true,
      builder: (_) => RelaysSheet(settings: settings),
    );
    _pausedBySheet.value = false;
  }

  Future<void> _openProfile() async {
    final p = _currentPost;
    if (p == null) return;
    _pausedBySheet.value = true;
    await showModalBottomSheet(
      context: context,
      backgroundColor: Colors.black,
      builder: (_) => ProfileSheet(
        controller: Locator.I.get<FeedController>(),
        pubkey: p.author.pubkey,
        displayName: p.author.name,
      ),
    );
    _pausedBySheet.value = false;
  }

  Future<void> _openDetails() async {
    final p = _currentPost;
    if (p == null) return;
    _pausedBySheet.value = true;
    await showModalBottomSheet(
      context: context,
      backgroundColor: Colors.black,
      builder: (_) => DetailsSheet(
        post: p,
        settings: settings,
        onMuted: () {
          final mut = settings.muted();
          Locator.I.get<FeedController>().setMuted(mut);
        },
      ),
    );
    _pausedBySheet.value = false;
  }

  Future<void> _zap() async {
    final controller = Locator.I.get<FeedController>();
    if (controller.posts.isEmpty) return;
    final p = controller.posts[controller.index];
    _pausedBySheet.value = true;
    await showModalBottomSheet(
      context: context,
      backgroundColor: Colors.black,
      builder: (_) => ZapSheet(
        lud16: 'tips@example.com',
        eventId: p.id,
        lightning: lightning,
      ),
    );
    _pausedBySheet.value = false;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          GestureDetector(
            key: const Key('feed-gesture'),
            behavior: HitTestBehavior.opaque,
            onTap: () {}, // play/pause will wire later
            onDoubleTap: _like,
            onLongPress: () => setState(() => overlaysVisible = !overlaysVisible),
            child: ValueListenableBuilder<bool>(
              valueListenable: _pausedBySheet,
              builder: (_, paused, __) => VideoPlayerView(globalPaused: paused),
            ),
          ),
          const _GradientScrim(top: true),
          const _GradientScrim(top: false),
          AnimatedOpacity(
            duration: const Duration(milliseconds: 220),
            opacity: overlaysVisible ? 1 : 0,
            child: OverlayCluster(
              onCreateTap: _openCreate,
              onLikeTap: _like,
              onCommentTap: _comment,
              onRepostTap: _repost,
              onQuoteTap: _openQuote,
              onZapTap: _zap,
              onProfileTap: _openProfile,
              onDetailsTap: _openDetails,
              onRelaysLongPress: _openRelays,
            ),
          ),
          ValueListenableBuilder<bool>(
            valueListenable: _pausedBySheet,
            builder: (_, paused, __) => paused
                ? const Positioned(
                    top: 8,
                    left: 0,
                    right: 0,
                    child: Center(
                      child: SizedBox(
                        key: Key('paused-banner'),
                        height: 6,
                        width: 80,
                      ),
                    ),
                  )
                : const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }
}

class _GradientScrim extends StatelessWidget {
  final bool top;
  const _GradientScrim({required this.top});
  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      ignoring: true,
      child: Align(
        alignment: top ? Alignment.topCenter : Alignment.bottomCenter,
        child: Container(
          height: 140,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: top ? Alignment.topCenter : Alignment.bottomCenter,
              end: top ? Alignment.bottomCenter : Alignment.topCenter,
              colors: const [Colors.black54, Colors.transparent],
            ),
          ),
        ),
      ),
    );
  }
}
