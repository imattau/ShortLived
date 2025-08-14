import 'package:flutter/material.dart';
import '../../data/models/post.dart';
import '../../services/settings/settings_service.dart';
import 'report_sheet.dart';

class DetailsSheet extends StatelessWidget {
  const DetailsSheet({
    super.key,
    required this.post,
    required this.settings,
    required this.onMuted,
  });
  final Post post;
  final SettingsService settings;
  final VoidCallback onMuted;

  @override
  Widget build(BuildContext context) {
    final meta = [
      'MIME: ${post.mime}',
      'Dim: ${post.width}x${post.height}',
      'Dur: ${post.duration.toStringAsFixed(1)}s',
    ];
    final isMarked = settings.sensitiveMarks().contains(post.id);
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
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
            Text(
              '@${post.author.name}',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 6),
            Text(post.caption),
            const SizedBox(height: 12),
            Text(
              meta.join('   '),
              style: const TextStyle(fontSize: 12, color: Colors.white70),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                ElevatedButton.icon(
                  onPressed: () async {
                    await settings.addMute(post.author.pubkey);
                    onMuted();
                    // ignore: use_build_context_synchronously
                    Navigator.of(context).maybePop();
                  },
                  icon: const Icon(Icons.volume_off),
                  label: const Text('Mute author'),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                OutlinedButton.icon(
                  onPressed: () async {
                    if (isMarked) {
                      await settings.removeSensitiveMark(post.id);
                      // ignore: use_build_context_synchronously
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Cleared sensitive mark')),
                      );
                    } else {
                      await settings.addSensitiveMark(post.id);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Marked as sensitive')),
                      );
                    }
                  },
                  icon: const Icon(Icons.shield),
                  label: Text(isMarked ? 'Clear sensitive' : 'Mark sensitive'),
                ),
                const SizedBox(width: 12),
                OutlinedButton.icon(
                  onPressed: () async {
                    await showModalBottomSheet(
                      context: context,
                      backgroundColor: Colors.black,
                      isScrollControlled: true,
                      builder: (_) => ReportSheet(eventId: post.id),
                    );
                  },
                  icon: const Icon(Icons.flag_outlined),
                  label: const Text('Report'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
