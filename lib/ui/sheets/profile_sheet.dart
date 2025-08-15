import 'package:flutter/material.dart';
import '../../state/feed_controller.dart';
import '../../data/models/post.dart';
import '../../services/moderation/mute_service.dart';
import '../../core/di/locator.dart';

class ProfileSheet extends StatelessWidget {
  const ProfileSheet({
    super.key,
    required this.controller,
    required this.pubkey,
    required this.displayName,
  });
  final FeedController controller;
  final String pubkey;
  final String displayName;

  @override
  Widget build(BuildContext context) {
    final posts = controller.posts
        .where((p) => p.author.pubkey == pubkey)
        .toList();
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              height: 4,
              width: 36,
              margin: const EdgeInsets.only(bottom: 12),
              decoration: BoxDecoration(
                color: Colors.white24,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Row(
              children: [
                CircleAvatar(
                  child: Text(displayName.isNotEmpty ? displayName[0] : '?'),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    displayName,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Builder(builder: (context) {
                  final isMuted = Locator.I.tryGet<MuteService>()?.current().users.contains(pubkey) ?? false;
                  return TextButton(
                    onPressed: () async {
                      final svc = Locator.I.get<MuteService>();
                      if (isMuted) {
                        await svc.unmuteUser(pubkey);
                      } else {
                        await svc.muteUser(pubkey);
                      }
                      // ignore: use_build_context_synchronously
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(isMuted ? 'Unmuted' : 'Muted')),
                      );
                    },
                    child: Text(isMuted ? 'Muted' : 'Mute'),
                  );
                }),
              ],
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: 300,
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  mainAxisSpacing: 4,
                  crossAxisSpacing: 4,
                ),
                itemCount: posts.length,
                itemBuilder: (_, i) => _Thumb(post: posts[i]),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Thumb extends StatelessWidget {
  final Post post;
  const _Thumb({required this.post});
  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        Image.network(
          post.thumb,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => Container(color: Colors.grey[800]),
        ),
      ],
    );
  }
}
