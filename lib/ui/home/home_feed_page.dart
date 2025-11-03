// ignore_for_file: unused_field, unused_element

import 'dart:async';
import 'package:flutter/material.dart';
import 'widgets/feed_video_player_view.dart';
import 'widgets/overlay_cluster.dart';
import 'widgets/create_button.dart';
import '../sheets/create_sheet.dart';
import '../sheets/comments_sheet.dart';
import '../sheets/zap_sheet.dart';
import '../sheets/profile_sheet.dart';
import '../sheets/details_sheet.dart';
import '../sheets/relays_sheet.dart';
import '../sheets/quote_sheet.dart';
import '../sheets/repost_sheet.dart';
import '../sheets/search_sheet.dart';
import '../sheets/settings_sheet.dart';
import '../sheets/notifications_sheet.dart';
import 'package:nostr_video/core/di/locator.dart';
import '../../core/config/network.dart';
import '../../core/config/app_config.dart';
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
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';
import '../../utils/capabilities.dart';
import '../../utils/count_format.dart';

class _RelayServiceStub implements RelayService {
  @override
  Future<void> init(List<String> relays) async {}

  @override
  Future<String> subscribe(
    List<Map<String, dynamic>> filters, {
    String? subId,
  }) async => 'sub';

  @override
  Future<void> close(String subId) async {}

  @override
  Stream<List<dynamic>> subscribeFeed({
    required List<String> authors,
    String? hashtag,
  }) => const Stream.empty();

  @override
  Future<String> publishEvent(Map<String, dynamic> signedEventJson) async =>
      'id';

  @override
  Future<String?> signAndPublish({
    required int kind,
    required String content,
    required List<List<String>> tags,
  }) async => 'id';

  @override
  Future<void> like({
    required String eventId,
    required String authorPubkey,
    String emojiOrPlus = '+',
  }) async {}

  @override
  Future<void> reply({
    required String parentId,
    required String content,
    String? parentPubkey,
    String? rootId,
    String? rootPubkey,
  }) async {}

  @override
  Future<void> quote({required String eventId, required String content}) async {}

  @override
  Future<void> repost({required String eventId, String? originalJson}) async {}

  @override
  Future<void> zapRequest({
    required String eventId,
    required int millisats,
  }) async {}

  @override
  Stream<Map<String, dynamic>> get events => const Stream.empty();

  @override
  Future<void> resetConnections(List<String> urls) async {}

  @override
  Future<Map<String, dynamic>> buildZapRequest({
    required String recipientPubkey,
    required String eventId,
    String content = '',
    List<String>? relays,
    int amountMsat = 0,
  }) async => {};
}

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
  SettingsService? settings;
  late ContentSafetyService safety;
  ActionQueue? queue;
  RelayDirectory? relayDir;
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
        NotificationsRepository(relay, signer, meta),
      );
    }
    Locator.I.get<NotificationsRepository>().start();
    final seenAt = settings.notifLastSeen();
    _notifSub = Locator.I.get<NotificationsRepository>().stream().listen((
      list,
    ) {
      final c = list.where((n) => n.createdAt > seenAt).length;
      if (mounted) setState(() => _unread = c);
    });
  }

  void _registerMuteService() {
    if (settings == null) return;
    if (Locator.I.tryGet<MuteService>() == null) {
      Locator.I.put<MuteService>(
        MuteService(settings!, Locator.I.get<RelayService>()),
      );
    }
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _init();
  }

  Future<void> _init() async {
    // Use a stub if no PwaService has been registered. Tests typically do not
    // bootstrap the service locator, so falling back keeps them isolated.
    _pwa = Locator.I.tryGet<PwaService>() ?? PwaServiceStub();
    if (!Locator.I.contains<MetadataService>()) {
      Locator.I.put<MetadataService>(MetadataService());
    }
    if (Locator.I.tryGet<KeyService>() == null) {
      Locator.I.put<KeyService>(KeyServiceSecure(const FlutterSecureStorage()));
    }
    settings =
        Locator.I.tryGet<SettingsService>() ??
        SettingsService(await SharedPreferences.getInstance());
    safety = ContentSafetyService(settings!);
    if (!Locator.I.contains<SettingsService>()) {
      Locator.I.put<SettingsService>(settings!);
    }
    overlaysVisible = !settings!.overlaysDefaultHidden();
    if (AppConfig.nostrEnabled) {
      relay =
          Locator.I.tryGet<RelayService>() ??
          RelayServiceWs(factory: (uri) => WebSocketChannel.connect(uri));
      if (!TestSwitches.disableRelays && !Locator.I.contains<RelayService>()) {
        await relay.init(NetworkConfig.relays);
        Locator.I.put<RelayService>(relay);
      }
      relayDir =
          Locator.I.tryGet<RelayDirectory>() ??
          RelayDirectory(settings!, relay, Locator.I.get<KeyService>());
      Locator.I.put<RelayDirectory>(relayDir!);
      await relayDir!.init();
      _zapSub = relay.events.listen((evt) {
        if (evt['kind'] == 9735) {
          final msats = int.tryParse((evt['amount'] ?? '0').toString()) ?? 0;
          final sats = (msats / 1000).round();
          if (mounted) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text('Received zap: $sats sats')));
          }
        }
      });
      queue = Locator.I.tryGet<ActionQueue>() ?? ActionQueueHive();
      if (!Locator.I.contains<ActionQueue>()) {
        await queue!.init();
        Locator.I.put<ActionQueue>(queue!);
      }
      if (!TestSwitches.disableRelays) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) {
            final c = Locator.I.tryGet<FeedController>();
            if (c != null) {
              c.bindQueue(queue!);
              c.setOnline(true, relay: Locator.I.get<RelayService>());
            }
          }
        });
      }
    } else {
      relay = Locator.I.tryGet<RelayService>() ?? _RelayServiceStub();
      if (!Locator.I.contains<RelayService>()) {
        Locator.I.put<RelayService>(relay);
      }
    }
    Locator.I.ensureSigner();
    _setupNotifications();
    _registerMuteService();
    if (mounted) {
      setState(() {});
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
      final c = Locator.I.tryGet<FeedController>();
      c?.replayQueue(relay);
    }
  }

  Post? get _currentPost {
    final c = Locator.I.tryGet<FeedController>();
    if (c == null || c.posts.isEmpty) return null;
    return c.posts[c.index];
  }

  void _like() {
    final controller = Locator.I.tryGet<FeedController>();
    controller?.likeCurrent(relay).then((ok) {
      if (!ok && mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Failed to like')));
      }
    });
  }

  Future<void> _repost() async {
    final c = Locator.I.tryGet<FeedController>();
    final p = c?.currentOrNull;
    if (c == null || p == null) return;
    final confirm = await showModalBottomSheet<bool>(
      context: context,
      backgroundColor: Colors.black,
      isDismissible: true,
      enableDrag: true,
      builder: (_) => RepostSheet(eventId: p.id),
    );
    if (confirm == true) {
      final r = Locator.I.get<RelayService>();
      c.repostCurrent(r);
    }
  }

  Future<void> _openQuote() async {
    final c = Locator.I.tryGet<FeedController>();
    final p = c?.currentOrNull;
    if (c == null || p == null) return;
    await showModalBottomSheet(
      context: context,
      backgroundColor: Colors.black,
      isScrollControlled: true,
      builder: (_) =>
          QuoteSheet(eventId: p.id, relay: Locator.I.get<RelayService>()),
    );
  }

  Future<void> _openComments() async {
    final c = Locator.I.tryGet<FeedController>();
    final p = c?.currentOrNull;
    if (c == null || p == null) return;
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
    final fc = Locator.I.tryGet<FeedController>();
    if (p == null || fc == null) return;
    _pausedBySheet.value = true;
    await showModalBottomSheet(
      context: context,
      backgroundColor: Colors.black,
      builder: (_) => ProfileSheet(
        controller: fc,
        pubkey: p.author.pubkey,
        displayName: p.author.name,
      ),
    );
    _pausedBySheet.value = false;
  }

  Future<void> _openDetails() async {
    final p = _currentPost;
    final s = settings;
    if (p == null || s == null) return;
    _pausedBySheet.value = true;
    await showModalBottomSheet(
      context: context,
      backgroundColor: Colors.black,
      builder: (_) => DetailsSheet(post: p, settings: s),
    );
    _pausedBySheet.value = false;
  }

  Future<void> _openSearch() async {
    await showModalBottomSheet(
      context: context,
      backgroundColor: Colors.black,
      isScrollControlled: true,
      isDismissible: true,
      enableDrag: true,
      barrierColor: Colors.black54,
      builder: (_) => const SearchSheet(),
    );
  }

  void _toggleSafety() {
    final s = settings;
    if (s == null) return;
    final next = !s.sensitiveBlurEnabled();
    s.setSensitiveBlurEnabled(next);
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

  void _shareOrCopy() async {
    final p = Locator.I.tryGet<FeedController>()?.currentOrNull;
    if (p == null) return;
    final link = neventEncode(
      eventIdHex: p.id,
      authorPubkeyHex: p.author.pubkey,
    );
    final shareText = 'nostr:$link';
    if (!Capabilities.shareSupported) {
      Clipboard.setData(ClipboardData(text: shareText));
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Link copied')));
      }
      return;
    }
    try {
      await Share.share(shareText);
    } catch (_) {
      await Clipboard.setData(ClipboardData(text: shareText));
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Link copied')));
      }
    }
  }

  void _copyLink() {
    final p = Locator.I.tryGet<FeedController>()?.currentOrNull;
    if (p == null) return;
    final link = neventEncode(
      eventIdHex: p.id,
      authorPubkeyHex: p.author.pubkey,
    );
    final shareText = 'nostr:$link';
    Clipboard.setData(ClipboardData(text: shareText));
    if (mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Link copied')));
    }
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
            child: Stack(
              children: [
                Align(
                  alignment: Alignment.centerRight,
                  child: OverlayCluster(
                    onLike: _like,
                    onComment: _openComments,
                    onRepost: _repost,
                    onShare: _shareOrCopy,
                    onCopyLink: _copyLink,
                    onZap: _openZap,
                    likeCount: formatCount(_currentPost?.likeCount ?? 0),
                    commentCount: formatCount(_currentPost?.commentCount ?? 0),
                    repostCount: formatCount(_currentPost?.repostCount ?? 0),
                    shareCount: '0',
                    zapCount: '0',
                  ),
                ),
                Positioned(
                  right: 12,
                  top: 8,
                  child: IconButton(
                    tooltip: 'Safety mode',
                    icon: Icon(
                      (settings?.sensitiveBlurEnabled() ?? false)
                          ? Icons.shield
                          : Icons.shield_outlined,
                    ),
                    onPressed: settings == null ? null : _toggleSafety,
                  ),
                ),
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 24 + MediaQuery.of(context).padding.bottom,
                  child: Center(
                    child: ValueListenableBuilder<bool>(
                      valueListenable: _pausedBySheet,
                      builder: (_, paused, __) => CreateButton(
                        onPressed: _openCreate,
                        hidden: !overlaysVisible || paused,
                      ),
                    ),
                  ),
                ),
              ],
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
