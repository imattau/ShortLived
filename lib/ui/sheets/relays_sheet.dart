import 'package:flutter/material.dart';
import '../../core/config/network.dart';
import '../../services/settings/settings_service.dart';
import '../../services/keys/key_service.dart';
import '../../crypto/nip19.dart';
import '../../core/di/locator.dart';
import 'package:flutter/services.dart';

class RelaysSheet extends StatefulWidget {
  const RelaysSheet({super.key, required this.settings});
  final SettingsService settings;

  @override
  State<RelaysSheet> createState() => _RelaysSheetState();
}

class _RelaysSheetState extends State<RelaysSheet> {
  late final TextEditingController _ctrl;
  late final TextEditingController _importCtrl;
  late List<String> _relays;
  late bool _overlaysHidden;

  @override
  void initState() {
    super.initState();
    _ctrl = TextEditingController();
    _importCtrl = TextEditingController();
    _relays = {...NetworkConfig.relays, ...widget.settings.relays()}.toList();
    _overlaysHidden = widget.settings.overlaysDefaultHidden();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    _importCtrl.dispose();
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
            /* Keys Section */
            const Divider(height: 24),
            Align(alignment: Alignment.centerLeft, child: Text('Keys', style: TextStyle(fontWeight: FontWeight.bold))),
            FutureBuilder<String?>(
              future: Locator.I.get<KeyService>().getPubkey(),
              builder: (_, snap) {
                final pub = snap.data;
                final npub = (pub == null) ? '' : Nip19.encodeNpub(pub);
                return Row(children: [
                  Expanded(child: Text(npub.isEmpty ? 'No key' : '${npub.substring(0,12)}…${npub.substring(npub.length-6)}')),
                  TextButton(onPressed: pub == null ? null : () => Clipboard.setData(ClipboardData(text: npub)), child: const Text('Copy')),
                ]);
              },
            ),
            Row(children: [
              Expanded(
                child: TextField(
                  key: const Key('import-nsec'),
                  controller: _importCtrl,
                  decoration: const InputDecoration(hintText: 'nsec1… or hex'),
                ),
              ),
              const SizedBox(width: 8),
              ElevatedButton(
                onPressed: () async {
                  final v = _importCtrl.text.trim();
                  if (v.isEmpty) return;
                  await Locator.I.get<KeyService>().importSecret(v);
                  if (!mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Key imported')));
                  setState(() {});
                },
                child: const Text('Import'),
              ),
            ]),
            Row(children: [
              ElevatedButton(
                onPressed: () async {
                  final ok = await showDialog<bool>(context: context, builder: (_) =>
                    AlertDialog(title: const Text('Export private key?'), content: const Text('Never share your nsec. Proceed?'),
                      actions: [TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
                                TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Export'))]));
                  if (ok != true) return;
                  final nsec = await Locator.I.get<KeyService>().exportNsec();
                  if (nsec == null) return;
                  await Clipboard.setData(ClipboardData(text: nsec));
                  if (!mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('nsec copied (handle with care)')));
                },
                child: const Text('Export nsec'),
              ),
              const SizedBox(width: 8),
              OutlinedButton(
                onPressed: () async {
                  final ok = await showDialog<bool>(context: context, builder: (_) =>
                    AlertDialog(title: const Text('Generate new key?'), content: const Text('This will replace your current key on this device.'),
                      actions: [TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
                                TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Generate'))]));
                  if (ok != true) return;
                  await Locator.I.get<KeyService>().generate();
                  if (!mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('New key generated')));
                  setState(() {});
                },
                child: const Text('Generate new key'),
              ),
            ]),
          ],
        ),
      ),
    );
  }
}
