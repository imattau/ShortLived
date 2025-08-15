import 'dart:async';
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
import '../sheets/search_sheet.dart';
import '../sheets/settings_sheet.dart';
import '../sheets/notifications_sheet.dart';
import 'package:nostr_video/core/di/locator.dart';
import '../../core/config/network.dart';
import '../../services/nostr/relay_service_ws.dart';
import '../../services/nostr/relay_service.dart';
import '../../services/settings/settings_service.dart';
import '../../services/safety/content_safety_service.dart';
import '../../state/feed_controller.dart';
import '../../data/models/post.dart';
import '../../services/queue/action_queue.dart';
import '../../services/queue/action_queue_hive.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../services/keys/key_service.dart';
import '../../services/keys/key_service_secure.dart';
import '../../services/keys/signer.dart';
import '../../services/moderation/mute_service.dart';
import '../../services/nostr/metadata_service.dart';
import '../../data/repos/notifications_repository.dart';
import '../../data/models/notification.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import '../../core/testing/test_switches.dart';
import '../../services/nostr/relay_directory.dart';
import '../../web/pwa/pwa_service.dart';
import '../../crypto/nip19.dart';
import 'package:share_plus/share_plus.dart';

class HomeFeedPage extends StatefulWidget {
  const HomeFeedPage({super.key});
  @override
  State<HomeFeedPage> createState() => _HomeFeedPageState();
}

class _HomeFeedPageState extends State<HomeFeedPage>
    with WidgetsBindingObserver {
  bool overlaysVisible = true;
  final ValueNotifier<bool> _pausedBySheet = ValueNotifier(false);
  late final RelayService relay;
  StreamSubscription<Map<String, dynamic>>? _zapSub;
  late SettingsService settings;
  late ContentSafetyService safety; // ignore: unused_field
  late ActionQueue queue;
  late RelayDirectory relayDir;
  late final PwaService _pwa;
  int _unread = 0;
  StreamSubscription<List<NotificationItem>>? _notifSub;

  Future<void> _openCreate() async {
    _pausedBySheet.value = true;
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.black,
      builder: (ctx) => const CreateSheet(),
    );
    _pausedBySheet.value = false;
  }

  void _setupNotifications() {
    if (TestSwitches.disableRelays) return;
    final relay = Locator.I.tryGet<RelayService>();
    final signer = Locator.I.tryGet<Signer>();
    final meta = Locator.I.tryGet<MetadataService>();
    final settings = Locator.I.tryGet<SettingsService>();
    if (relay == null || signer == null || meta == null || settings == null) {
      return;
    }
    if (Locator.I.tryGet<NotificationsRepository>() == null) {
      Locator.I.put<NotificationsRepository>(
          NotificationsRepository(relay, signer, meta));
    }
    Locator.I.get<NotificationsRepository>().start();
    final seenAt = settings.notifLastSeen();
    _notifSub =
        Locator.I.get<NotificationsRepository>().stream().listen((list) {
      final c = list.where((n) => n.createdAt > seenAt).length;
      if (mounted) setState(() => _unread = c);
    });
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    // Use a stub if no PwaService has been registered. Tests typically do not
    // bootstrap the service locator, so falling back keeps them isolated.
    _pwa = Locator.I.tryGet<PwaService>() ?? PwaServiceStub();
      if (Locator.I.tryGet<KeyService>() == null) {
        Locator.I.put<KeyService>(KeyServiceSecure(const FlutterSecureStorage()));
      }
      relay = Locator.I.tryGet<RelayService>() ??
          RelayServiceWs(factory: (uri) => WebSocketChannel.connect(uri));
    if (!TestSwitches.disableRelays && !Locator.I.contains<RelayService>()) {
      relay.init(NetworkConfig.relays);
      Locator.I.put<RelayService>(relay);
    }
    relayDir = Locator.I.tryGet<RelayDirectory>() ??
        RelayDirectory(Locator.I.get(), Locator.I.get(), Locator.I.get());
    Locator.I.put<RelayDirectory>(relayDir);
    // On production runs, apply NIP-65; tests have disableRelays = true.
    relayDir.init();
    _zapSub = relay.events.listen((evt) {
      if (evt['kind'] == 9735) {
        final msats = int.tryParse((evt['amount'] ?? '0').toString()) ?? 0;
        final sats = (msats / 1000).round();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Received zap: $sats sats')));
        }
      }
    });
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
      safety = ContentSafetyService(settings);
      overlaysVisible = !settings.overlaysDefaultHidden();
      Locator.I.ensureSigner();
      _setupNotifications();
    } else {
      SharedPreferences.getInstance().then((sp) {
        settings = SettingsService(sp);
        safety = ContentSafetyService(settings);
        Locator.I.put<SettingsService>(settings);
        Locator.I.ensureSigner();
        _setupNotifications();
        if (mounted) {
          setState(() {
            overlaysVisible = !settings.overlaysDefaultHidden();
          });
        }
      });
    }
    if (Locator.I.tryGet<MuteService>() == null) {
      Locator.I.put<MuteService>(MuteService(
        Locator.I.get<SettingsService>(),
        Locator.I.get<RelayService>(),
      ));
    }
  }

  @override
  void dispose() {
    _notifSub?.cancel();
    _zapSub?.cancel();
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
      builder: (_) =>
          QuoteSheet(eventId: p.id, relay: Locator.I.get<RelayService>()),
    );
  }

  Future<void> _openComments() async {
    final c = Locator.I.get<FeedController>();
    final p = c.currentOrNull;
    if (p == null) return;
    _pausedBySheet.value = true;
    await showModalBottomSheet(
      context: context,
      backgroundColor: Colors.black,
      isScrollControlled: true,
      builder: (_) => CommentsSheet(post: p),
    );
    _pausedBySheet.value = false;
  }

  Future<void> _openRelays() async {
    _pausedBySheet.value = true;
    await showModalBottomSheet(
      context: context,
      backgroundColor: Colors.black,
      isScrollControlled: true,
      builder: (_) => const RelaysSheet(),
    );
    _pausedBySheet.value = false;
  }

  Future<void> _openSettings() async {
    _pausedBySheet.value = true;
    await showModalBottomSheet(
      context: context,
      backgroundColor: Colors.black,
      isScrollControlled: true,
      builder: (_) => const SettingsSheet(),
    );
    _pausedBySheet.value = false;
  }

  Future<void> _openNotifications() async {
    await showModalBottomSheet(
      context: context,
      backgroundColor: Colors.black,
      isScrollControlled: true,
      builder: (_) => const NotificationsSheet(),
    );
    final seenAt = Locator.I.get<SettingsService>().notifLastSeen();
    final list = await Locator.I
        .get<NotificationsRepository>()
        .stream()
        .firstWhere((_) => true, orElse: () => const []);
    final c = list.where((n) => n.createdAt > seenAt).length;
    if (mounted) setState(() => _unread = c);
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
      ),
    );
    _pausedBySheet.value = false;
  }

  Future<void> _openSearch() async {
    await showModalBottomSheet(
      context: context,
      backgroundColor: Colors.black,
      isScrollControlled: true,
      builder: (_) => const SearchSheet(),
    );
  }

  void _toggleSafety() {
    final next = !settings.sensitiveBlurEnabled();
    settings.setSensitiveBlurEnabled(next);
    setState(() {});
  }

  Future<void> _openZap() async {
    await showModalBottomSheet(
      context: context,
      backgroundColor: Colors.black,
      isScrollControlled: true,
      builder: (_) => const ZapSheet(),
    );
  }

  void _shareCurrent() {
    final p = Locator.I.get<FeedController>().currentOrNull;
    if (p == null) return;
    final link =
        neventEncode(eventIdHex: p.id, authorPubkeyHex: p.author.pubkey);
    Share.share('nostr:$link');
  }

  Future<void> _promptInstall() async {
    final ok = await _pwa.promptInstall();
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(ok ? 'Installing…' : 'Install declined')),
    );
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
            onLongPress: () =>
                setState(() => overlaysVisible = !overlaysVisible),
            child: ValueListenableBuilder<bool>(
              valueListenable: _pausedBySheet,
              builder: (_, paused, __) => VideoPlayerView(globalPaused: paused),
            ),
          ),
          const _GradientScrim(top: true),
          const _GradientScrim(top: false),
          AnimatedOpacity(
            key: const Key('overlay-visibility'),
            duration: const Duration(milliseconds: 220),
            opacity: overlaysVisible ? 1 : 0,
            child: ValueListenableBuilder<bool>(
              valueListenable: _pwa.installAvailable,
              builder: (_, avail, __) => OverlayCluster(
                onCreateTap: _openCreate,
                onLikeTap: _like,
                onCommentTap: _openComments,
                onRepostTap: _repost,
                onQuoteTap: _openQuote,
                onZapTap: _openZap,
                onProfileTap: _openProfile,
                onDetailsTap: _openDetails,
                onRelaysLongPress: _openRelays,
                onSearchTap: _openSearch,
                onSettingsTap: _openSettings,
                onNotificationsTap: _openNotifications,
                unreadCount: _unread,
                safetyOn: settings.sensitiveBlurEnabled(),
                onSafetyToggle: _toggleSafety,
                onShareTap: _shareCurrent,
                showInstall: avail,
                onInstallTap: avail ? _promptInstall : null,
              ),
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
