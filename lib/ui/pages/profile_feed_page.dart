import 'package:flutter/material.dart';
import '../../core/di/locator.dart';
import '../../data/models/post.dart';
import '../../state/feed_controller.dart';
import '../../crypto/nip19.dart';
import 'package:share_plus/share_plus.dart';

class ProfileFeedPage extends StatefulWidget {
  final String handle; // npub / nprofile TLV / hex pubkey allowed
  const ProfileFeedPage({super.key, required this.handle});
  @override
  State<ProfileFeedPage> createState() => _ProfileFeedPageState();
}

class _ProfileFeedPageState extends State<ProfileFeedPage> {
  String? _pubkeyHex;
  List<Post> _posts = const [];

  @override
  void initState() {
    super.initState();
    _resolve();
  }

  Future<void> _resolve() async {
    final h = widget.handle;
    String? hex;
    if (isNpub(h)) {
      hex = nip19Decode(h);
    } else if (h.startsWith('nprofile1')) {
      hex = null; // Minimal decode not implemented
    } else if (RegExp(r'^[0-9a-fA-F]{64}$').hasMatch(h)) {
      hex = h;
    }
    setState(() => _pubkeyHex = hex);
    final fc = Locator.I.get<FeedController>();
    setState(() =>
        _posts = fc.posts.where((p) => hex != null && p.author.pubkey == hex).toList());
  }

  void _shareProfile() {
    final pk = _pubkeyHex;
    if (pk == null) return;
    final link = nprofileEncode(pubkeyHex: pk);
    Share.share('nostr:$link');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Profile'), actions: [
        IconButton(icon: const Icon(Icons.share), onPressed: _shareProfile),
      ]),
      body: ListView.builder(
        itemCount: _posts.length,
        itemBuilder: (_, i) {
          final p = _posts[i];
          return ListTile(
            title: Text(p.caption,
                maxLines: 2, overflow: TextOverflow.ellipsis),
            subtitle: Text('@${p.author.name}'),
            onTap: () =>
                Navigator.of(context).pushNamed('/event', arguments: p.id),
          );
        },
      ),
    );
  }
}
