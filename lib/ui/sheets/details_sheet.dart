import 'package:flutter/material.dart';
import '../../data/models/post.dart';
import '../../services/settings/settings_service.dart';
import '../../services/moderation/mute_service.dart';
import '../../core/di/locator.dart';
import '../sheets/muted_sheet.dart';
import 'report_sheet.dart';

class DetailsSheet extends StatelessWidget {
  const DetailsSheet({
    super.key,
    required this.post,
    required this.settings,
  });
  final Post post;
  final SettingsService settings;

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
                OutlinedButton.icon(
                  icon: const Icon(Icons.volume_off),
                  label: const Text('Mute tag'),
                  onPressed: () async {
                    final tag = _firstHashtagOrNullFrom(post.caption);
                    if (tag == null) return;
                    await Locator.I.get<MuteService>().muteTag(tag);
                    // ignore: use_build_context_synchronously
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Muted #$tag')),
                    );
                  },
                ),
                const SizedBox(width: 8),
                OutlinedButton.icon(
                  icon: const Icon(Icons.visibility_off),
                  label: const Text('Mute word'),
                  onPressed: () async {
                    final word = await _promptWord(context);
                    if (word == null || word.trim().isEmpty) return;
                    await Locator.I.get<MuteService>().muteWord(word.trim());
                    // ignore: use_build_context_synchronously
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Word muted')),
                    );
                  },
                ),
                const SizedBox(width: 8),
                OutlinedButton.icon(
                  icon: const Icon(Icons.block),
                  label: const Text('Mute post'),
                  onPressed: () async {
                    await Locator.I.get<MuteService>().muteEvent(post.id);
                    // ignore: use_build_context_synchronously
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Post muted')),
                    );
                  },
                ),
                const SizedBox(width: 8),
                TextButton(
                  onPressed: () async {
                    await showModalBottomSheet(
                      context: context,
                      backgroundColor: Colors.black,
                      isScrollControlled: true,
                      builder: (_) => const MutedSheet(),
                    );
                  },
                  child: const Text('Manage muted…'),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                OutlinedButton.icon(
                  onPressed: () async {
                    String msg;
                    if (isMarked) {
                      await settings.removeSensitiveMark(post.id);
                      msg = 'Cleared sensitive mark';
                    } else {
                      await settings.addSensitiveMark(post.id);
                      msg = 'Marked as sensitive';
                    }
                    if (context.mounted) {
                      ScaffoldMessenger.of(context)
                          .showSnackBar(SnackBar(content: Text(msg)));
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

String? _firstHashtagOrNullFrom(String text) {
  final m = RegExp(r'(?:^|\s)#([a-z0-9_]{1,40})', caseSensitive: false).firstMatch(text);
  return m == null ? null : m.group(1)!.toLowerCase();
}

Future<String?> _promptWord(BuildContext context) async {
  final ctrl = TextEditingController();
  return showDialog<String>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: const Text('Mute word'),
      content: TextField(controller: ctrl),
      actions: [
        TextButton(onPressed: () => Navigator.of(ctx).pop(), child: const Text('Cancel')),
        TextButton(onPressed: () => Navigator.of(ctx).pop(ctrl.text.trim()), child: const Text('OK')),
      ],
    ),
  );
}
