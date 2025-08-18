import 'package:flutter/material.dart';
import '../../core/di/locator.dart';
import '../../state/feed_controller.dart';
import '../../services/lightning/zap_service.dart';
import '../../services/nostr/metadata_service.dart';

class ZapSheet extends StatefulWidget {
  const ZapSheet({super.key});
  @override
  State<ZapSheet> createState() => _ZapSheetState();
}

class _ZapSheetState extends State<ZapSheet> {
  int _sats = 100; // default
  bool _loading = false;
  final _note = TextEditingController();

  @override
  void dispose() {
    _note.dispose();
    super.dispose();
  }

  Future<void> _zap() async {
    final c = Locator.I.get<FeedController>();
    final p = c.currentOrNull;
    if (p == null || _loading) return;

    setState(() => _loading = true);
    try {
      await ZapService.instance.zap(
        post: p,
        amountSats: _sats,
        comment: _note.text.trim().isEmpty ? null : _note.text.trim(),
      );
      if (mounted) Navigator.of(context).maybePop();
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text('Zap sent')));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Zap failed: $e')));
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final c = Locator.I.get<FeedController>();
    final p = c.currentOrNull;
    final meta =
        p == null ? null : Locator.I.tryGet<MetadataService>()?.get(p.author.pubkey);
    final who = meta?.name ?? p?.author.name ?? '';

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
                    borderRadius: BorderRadius.circular(2))),
            Text('Zap $who', style: const TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Row(
              children: [
                const Text('Sats'),
                Expanded(
                  child: Slider(
                    value: _sats.toDouble(),
                    min: 10,
                    max: 10000,
                    divisions: 100,
                    label: '$_sats',
                    onChanged: _loading
                        ? null
                        : (v) => setState(() => _sats = v.round()),
                  ),
                ),
                SizedBox(
                    width: 56,
                    child: Text('$_sats', textAlign: TextAlign.right)),
              ],
            ),
            TextField(
                controller: _note,
                minLines: 1,
                maxLines: 3,
                decoration:
                    const InputDecoration(hintText: 'Add a note (optional)')),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                  onPressed: _loading ? null : _zap,
                  child: _loading
                      ? const CircularProgressIndicator()
                      : const Text('Zap')),
            ),
          ],
        ),
      ),
    );
  }
}
