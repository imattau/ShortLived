import 'package:flutter/material.dart';
import '../../core/di/locator.dart';
import '../../state/feed_controller.dart';
import '../../crypto/nip19.dart';
import 'package:share_plus/share_plus.dart';

class EventViewPage extends StatelessWidget {
  final String encoded; // id hex OR nevent/note
  const EventViewPage({super.key, required this.encoded});

  @override
  Widget build(BuildContext context) {
    final fc = Locator.I.get<FeedController>();
    final p = fc.posts.firstWhere(
      (x) => x.id == encoded,
      orElse: () => fc.currentOrNull ?? fc.posts.first,
    );
    void share() {
      final link = neventEncode(
          eventIdHex: p.id, authorPubkeyHex: p.author.pubkey);
      Share.share('nostr:$link');
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Post'), actions: [
        IconButton(icon: const Icon(Icons.share), onPressed: share),
      ]),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(p.caption, style: const TextStyle(fontSize: 16)),
              const SizedBox(height: 8),
              Text('@${p.author.name}',
                  style: const TextStyle(color: Colors.white70)),
              const Divider(),
              const Text(
                  'Video playback omitted here — open from feed for full view'),
            ]),
      ),
    );
  }
}
