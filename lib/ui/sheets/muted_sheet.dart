import 'package:flutter/material.dart';
import '../../core/di/locator.dart';
import '../../services/moderation/mute_service.dart';

class MutedSheet extends StatefulWidget {
  const MutedSheet({super.key});
  @override
  State<MutedSheet> createState() => _MutedSheetState();
}

class _MutedSheetState extends State<MutedSheet> {
  @override
  Widget build(BuildContext context) {
    final svc = Locator.I.get<MuteService>();
    final list = svc.current();

    Chip item(String label, Future<void> Function() onDelete) => Chip(
      label: Text(label),
      deleteIcon: const Icon(Icons.close),
      onDeleted: () async {
        await onDelete();
        if (mounted) setState(() {});
      },
    );

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                height: 4,
                width: 36,
                margin: const EdgeInsets.only(bottom: 12),
                decoration: BoxDecoration(
                    color: Colors.white24,
                    borderRadius: BorderRadius.circular(2)),
              ),
              const Text('Muted',
                  style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              const Text('Users'),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: list.users
                    .map((pk) => item('@${pk.substring(0, 8)}', () => svc.unmuteUser(pk)))
                    .toList(),
              ),
              const SizedBox(height: 12),
              const Text('Hashtags'),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: list.tags
                    .map((t) => item('#$t', () => svc.unmuteTag(t)))
                    .toList(),
              ),
              const SizedBox(height: 12),
              const Text('Words'),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: list.words
                    .map((w) => item(w, () => svc.unmuteWord(w)))
                    .toList(),
              ),
              const SizedBox(height: 12),
              const Text('Posts'),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: list.events
                    .map((id) => item(id.substring(0, 8), () => svc.unmuteEvent(id)))
                    .toList(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
