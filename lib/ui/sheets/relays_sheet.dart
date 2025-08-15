import 'package:flutter/material.dart';
import '../../services/nostr/relay_directory.dart';
import '../../core/di/locator.dart';

class RelaysSheet extends StatefulWidget {
  const RelaysSheet({super.key});
  @override
  State<RelaysSheet> createState() => _RelaysSheetState();
}

class _RelaysSheetState extends State<RelaysSheet> {
  final _ctrl = TextEditingController();

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final dir = Locator.I.get<RelayDirectory>();
    final relays = dir.current();

    Widget item(RelayEntry e) {
      return ListTile(
        dense: true,
        title: Text(e.uri.toString()),
        trailing: Wrap(spacing: 8, children: [
          FilterChip(
            label: const Text('Read'),
            selected: e.read,
            onSelected: (v) async {
              await dir.setFlags(e.uri.toString(), read: v);
              setState(() {});
            },
          ),
          FilterChip(
            label: const Text('Write'),
            selected: e.write,
            onSelected: (v) async {
              await dir.setFlags(e.uri.toString(), write: v);
              setState(() {});
            },
          ),
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: () async {
              await dir.remove(e.uri.toString());
              setState(() {});
            },
          ),
        ]),
      );
    }

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
            Align(
              alignment: Alignment.centerLeft,
              child: const Text('Relays',
                  style: TextStyle(fontWeight: FontWeight.bold)),
            ),
            const SizedBox(height: 8),
            ...relays.map(item),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _ctrl,
                    decoration:
                        const InputDecoration(hintText: 'wss://relay.example'),
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: () async {
                    final v = _ctrl.text.trim();
                    if (v.isEmpty) return;
                    await dir.add(v);
                    _ctrl.clear();
                    setState(() {});
                  },
                  child: const Text('Add'),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                OutlinedButton(
                  onPressed: () async {
                    await dir.init();
                    if (mounted) setState(() {});
                  },
                  child: const Text('Sync from profile'),
                ),
                const SizedBox(width: 8),
                const Expanded(
                  child: Text(
                    'Pull kind:10002 from your profile and apply if newer',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
