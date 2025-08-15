import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/di/locator.dart';
import '../../services/nostr/relay_service.dart';
import '../../services/lightning/lightning_service.dart';
import '../../services/nostr/metadata_service.dart';
import '../../state/feed_controller.dart';
import '../../services/keys/key_service.dart';

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
      final meta = Locator.I.tryGet<MetadataService>()?.get(p.author.pubkey);
      final addr = meta?.lud16?.isNotEmpty == true ? meta!.lud16! : null;
      final lnurl = meta?.lud06?.isNotEmpty == true ? meta!.lud06! : null;
      if (addr == null && lnurl == null) {
        throw Exception('No lightning address');
      }

      final relay = Locator.I.get<RelayService>();
      final zapReq = await relay.buildZapRequest(
        recipientPubkey: p.author.pubkey,
        eventId: p.id,
        content: _note.text.trim(),
      );

      final l = Locator.I.tryGet<LightningService>() ??
          LnurlLightningService(Dio(), Locator.I.get<KeyService>());
      final params = addr != null
          ? await l.fetchParamsFromAddress(addr)
          : await l.fetchParamsFromLnurl(lnurl!);
      final inv = await l.requestInvoice(
        params: params,
        amountSats: _sats,
        zapRequest9734: zapReq,
        comment: _note.text.trim().isEmpty ? null : _note.text.trim(),
      );

      final uri = Uri.parse('lightning:${inv.bolt11}');
      if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
        throw Exception('No wallet found to handle invoice');
      }

      if (mounted) Navigator.of(context).maybePop();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Opened wallet for $_sats sats')));
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
