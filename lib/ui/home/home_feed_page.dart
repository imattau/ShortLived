import 'package:flutter/material.dart';
import 'widgets/video_player_view.dart';
import 'widgets/overlay_cluster.dart';
import '../sheets/create_sheet.dart';
import '../sheets/comments_sheet.dart';
import '../sheets/zap_sheet.dart';
import '../sheets/profile_sheet.dart';
import '../sheets/details_sheet.dart';
import '../sheets/relays_sheet.dart';
import '../../core/di/locator.dart';
import '../../core/config/network.dart';
import '../../services/nostr/relay_service_ws.dart';
import '../../services/nostr/relay_service.dart';
import '../../services/lightning/lightning_service_lnurl.dart';
import '../../services/settings/settings_service.dart';
import '../../state/feed_controller.dart';
import '../../data/models/post.dart';
import '../../services/queue/action_queue.dart';
import '../../services/queue/action_queue_hive.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

class HomeFeedPage extends StatefulWidget {
  const HomeFeedPage({super.key});
  @override
  State<HomeFeedPage> createState() => _HomeFeedPageState();
}

class _HomeFeedPageState extends State<HomeFeedPage> with WidgetsBindingObserver {
  bool overlaysVisible = true;
  bool pausedBySheet = false;
  late final RelayService relay;
  late final LightningServiceLnurl lightning;
  late SettingsService settings;
  late ActionQueue queue;

  Future<void> _openCreate() async {
    setState(() => pausedBySheet = true);
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.black,
      builder: (ctx) => CreateSheet(
        onCreated: (post) {
          // TODO: route to controller to insert
          // We can find the nearest State of VideoPlayerView or keep a scoped controller
        },
      ),
    );
    if (mounted) setState(() => pausedBySheet = false);
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    relay = RelayServiceWs(factory: (uri) => WebSocketChannel.connect(uri));
    relay.init(NetworkConfig.relays);
    Locator.I.put<RelayService>(relay);
    lightning = LightningServiceLnurl(relay);
    queue = ActionQueueHive();
    queue.init();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        final c = Locator.I.get<FeedController>();
        c.bindQueue(queue);
        c.setOnline(true, relay: Locator.I.get<RelayService>());
      }
    });
    SharedPreferences.getInstance().then((sp) {
      settings = SettingsService(sp);
      Locator.I.put<SettingsService>(settings);
      Locator.I.get<FeedController>().setMuted(settings.muted());
      setState(() {
        overlaysVisible = !settings.overlaysDefaultHidden();
      });
    });
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

  Future<void> _comment() async {
    final controller = Locator.I.get<FeedController>();
    if (controller.posts.isEmpty) return;
    final p = controller.posts[controller.index];
    setState(() => pausedBySheet = true);
    await showModalBottomSheet(
      context: context,
      backgroundColor: Colors.black,
      builder: (_) => CommentsSheet(
        parentEventId: p.id,
        parentPubkey: p.author.pubkey,
        relay: relay,
      ),
    );
    if (mounted) setState(() => pausedBySheet = false);
  }

  Future<void> _openRelays() async {
    setState(() => pausedBySheet = true);
    await showModalBottomSheet(
      context: context,
      backgroundColor: Colors.black,
      isScrollControlled: true,
      builder: (_) => RelaysSheet(settings: settings),
    );
    if (mounted) setState(() => pausedBySheet = false);
  }

  Future<void> _openProfile() async {
    final p = _currentPost;
    if (p == null) return;
    setState(() => pausedBySheet = true);
    await showModalBottomSheet(
      context: context,
      backgroundColor: Colors.black,
      builder: (_) => ProfileSheet(
        controller: Locator.I.get<FeedController>(),
        pubkey: p.author.pubkey,
        displayName: p.author.name,
      ),
    );
    if (mounted) setState(() => pausedBySheet = false);
  }

  Future<void> _openDetails() async {
    final p = _currentPost;
    if (p == null) return;
    setState(() => pausedBySheet = true);
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
    if (mounted) setState(() => pausedBySheet = false);
  }

  Future<void> _zap() async {
    final controller = Locator.I.get<FeedController>();
    if (controller.posts.isEmpty) return;
    final p = controller.posts[controller.index];
    setState(() => pausedBySheet = true);
    await showModalBottomSheet(
      context: context,
      backgroundColor: Colors.black,
      builder: (_) => ZapSheet(
        lud16: 'tips@example.com',
        eventId: p.id,
        lightning: lightning,
      ),
    );
    if (mounted) setState(() => pausedBySheet = false);
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
            child: const VideoPlayerView(),
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
              onZapTap: _zap,
              onProfileTap: _openProfile,
              onDetailsTap: _openDetails,
              onRelaysLongPress: _openRelays,
            ),
          ),
          if (pausedBySheet)
            const Positioned(
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
