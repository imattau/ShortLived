import 'package:flutter/material.dart';
import '../../core/config/network.dart';
import '../../services/settings/settings_service.dart';

class RelaysSheet extends StatefulWidget {
  const RelaysSheet({super.key, required this.settings});
  final SettingsService settings;

  @override
  State<RelaysSheet> createState() => _RelaysSheetState();
}

class _RelaysSheetState extends State<RelaysSheet> {
  late final TextEditingController _ctrl;
  late List<String> _relays;
  late bool _overlaysHidden;

  @override
  void initState() {
    super.initState();
    _ctrl = TextEditingController();
    _relays = {...NetworkConfig.relays, ...widget.settings.relays()}.toList();
    _overlaysHidden = widget.settings.overlaysDefaultHidden();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
                const Text('Relays',
                    style: TextStyle(fontWeight: FontWeight.bold)),
                const Spacer(),
                IconButton(
                    onPressed: () => Navigator.of(context).maybePop(),
                    icon: const Icon(Icons.close)),
              ],
            ),
            const SizedBox(height: 4),
            SwitchListTile(
              title: const Text('Overlays default to hidden on open'),
              value: _overlaysHidden,
              onChanged: (v) async {
                setState(() => _overlaysHidden = v);
                await widget.settings.setOverlaysDefaultHidden(v);
              },
            ),
            const SizedBox(height: 4),
            SizedBox(
              height: 72,
              child: ListView(
                children: _relays
                    .map((r) => ListTile(
                          dense: true,
                          title: Text(r),
                          trailing: const Icon(Icons.check, size: 18),
                        ))
                    .toList(),
              ),
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                Expanded(
                    child: SizedBox(
                        height: 36,
                        child: TextField(
                            controller: _ctrl,
                            decoration: const InputDecoration(
                                hintText: 'wss://your-relay.example')))),
                const SizedBox(width: 8),
                SizedBox(
                  height: 36,
                  child: ElevatedButton(
                      onPressed: () {
                        final v = _ctrl.text.trim();
                        if (v.isEmpty) return;
                        setState(() {
                          _relays.add(v);
                          _ctrl.clear();
                        });
                        widget.settings.setRelays(_relays);
                      },
                      child: const Text('Add')),
                ),
              ],
            ),
            const SizedBox(height: 4),
            SizedBox(
              height: 36,
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () {
                  // Stub only
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                      content: Text('Export keys not implemented')));
                },
                icon: const Icon(Icons.key_outlined),
                label: const Text('Export keys'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
