import 'package:flutter/material.dart';
import '../../core/di/locator.dart';
import '../../services/keys/key_service.dart';
import '../../crypto/nip19.dart';
import 'package:qr_flutter/qr_flutter.dart';

class KeyManagementSheet extends StatefulWidget {
  const KeyManagementSheet({super.key});
  @override
  State<KeyManagementSheet> createState() => _KeyManagementSheetState();
}

class _KeyManagementSheetState extends State<KeyManagementSheet> {
  String? _pubHex;
  String? _privHex;
  final _importCtrl = TextEditingController();
  bool _busy = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final ks = Locator.I.tryGet<KeyService>();
    if (ks == null) return;
    final pub = await ks.getPubkey();
    final priv = await ks.getPrivkey();
    if (!mounted) return;
    setState(() {
      _pubHex = pub;
      _privHex = priv;
    });
  }

  Future<void> _generate() async {
    if (_busy) return;
    final ks = Locator.I.tryGet<KeyService>();
    if (ks == null) return;
    setState(() => _busy = true);
    try {
      await ks.generate();
      await _load();
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('New key generated')));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _import() async {
    if (_busy) return;
    final ks = Locator.I.tryGet<KeyService>();
    if (ks == null) return;
    final raw = _importCtrl.text.trim();
    if (raw.isEmpty) return;
    setState(() => _busy = true);
    try {
      String? hex;
      if (isNsec(raw)) {
        hex = nip19Decode(raw);
      } else if (RegExp(r'^[0-9a-fA-F]{64}$').hasMatch(raw)) {
        hex = raw;
      } else {
        throw Exception('Paste an nsec… or 64-char hex secret');
      }
      await ks.importSecret(hex!);
      await _load();
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Key imported')));
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Import failed: $e')));
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _clear() async {
    if (_busy) return;
    final ks = Locator.I.tryGet<KeyService>();
    if (ks == null) return;
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Clear keys from this device?'),
        content: const Text(
            'You will not be able to publish until you import or generate a new key.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel')),
          ElevatedButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Clear')),
        ],
      ),
    );
    if (ok != true) return;
    setState(() => _busy = true);
    try {
      await ks.importSecret('');
      await _load();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Keys cleared on this device')));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  void dispose() {
    _importCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final pubHex = _pubHex;
    final privHex = _privHex;
    final npub =
        (pubHex != null && pubHex.isNotEmpty) ? npubEncode(pubHex) : '';
    final nsec =
        (privHex != null && privHex.isNotEmpty) ? nsecEncode(privHex) : '';

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 20),
        child: SingleChildScrollView(
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
                      borderRadius: BorderRadius.circular(2))),
              const Text('Keys',
                  style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              const Text('Public key (npub)'),
              const SizedBox(height: 6),
              SelectableText(npub.isEmpty ? 'No local key' : npub,
                  style: const TextStyle(fontFamily: 'monospace')),
              const SizedBox(height: 8),
              if (npub.isNotEmpty)
                Center(
                    child: QrImageView(
                        data: npub,
                        version: QrVersions.auto,
                        size: 160)),
              const SizedBox(height: 16),
              const Text('Secret key (nsec)'),
              const SizedBox(height: 6),
              if (nsec.isEmpty)
                const Text(
                    'Not stored on this device (using browser signer or not generated).')
              else
                SelectableText(nsec,
                    style: const TextStyle(
                        fontFamily: 'monospace', color: Colors.orange)),
              const SizedBox(height: 8),
              if (nsec.isNotEmpty)
                Center(
                    child: QrImageView(
                        data: nsec,
                        version: QrVersions.auto,
                        size: 160)),
              if (nsec.isNotEmpty)
                const Padding(
                  padding: EdgeInsets.only(top: 6),
                  child: Text(
                      'Keep this private. Anyone with nsec can post as you.',
                      style: TextStyle(color: Colors.redAccent)),
                ),
              const SizedBox(height: 16),
              Row(children: [
                Expanded(
                  child: TextField(
                    controller: _importCtrl,
                    minLines: 1,
                    maxLines: 3,
                    decoration: const InputDecoration(
                        hintText: 'Paste nsec… or 64-char hex to import'),
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                    onPressed: _busy ? null : _import,
                    child: const Text('Import')),
              ]),
              const SizedBox(height: 12),
              Row(children: [
                ElevatedButton(
                    onPressed: _busy ? null : _generate,
                    child: const Text('Generate new')),
                const SizedBox(width: 8),
                OutlinedButton(
                    onPressed: _busy ? null : _clear,
                    child: const Text('Clear from device')),
              ]),
              const SizedBox(height: 8),
              const Text(
                  'Note: On web you can also use a NIP-07 browser wallet (see Settings → Signer).'),
            ],
          ),
        ),
      ),
    );
  }
}

