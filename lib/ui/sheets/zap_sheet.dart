import 'dart:async';
import 'package:flutter/material.dart';
import '../../services/lightning/lightning_service.dart';

class ZapSheet extends StatefulWidget {
  const ZapSheet(
      {super.key,
      required this.lud16,
      required this.eventId,
      required this.lightning});
  final String lud16;
  final String eventId;
  final LightningService lightning;

  @override
  State<ZapSheet> createState() => _ZapSheetState();
}

class _ZapSheetState extends State<ZapSheet> {
  StreamSubscription? _sub;
  String status = 'Ready';
  final amounts = const [500, 1000, 5000]; // millisats

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }

  Future<void> _zap(int msats) async {
    final ln = widget.lightning.buildLnurl(widget.lud16, msats, note: 'Zap');
    setState(() => status = 'Opening wallet…');
    try {
      final dyn = widget.lightning as dynamic;
      if (dyn.openWallet is Function) {
        await dyn.openWallet(ln);
      }
      _sub?.cancel();
      _sub = widget.lightning.listenForZapReceipts(widget.eventId).listen((_) {
        if (mounted) setState(() => status = 'Zap received');
      });
      if (mounted) setState(() => status = 'Waiting for receipt…');
    } catch (e) {
      if (mounted) setState(() => status = 'Failed: $e');
    }
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
                    borderRadius: BorderRadius.circular(2))),
            Text('Send a zap to ${widget.lud16}'),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: amounts
                  .map((a) => ElevatedButton(
                      onPressed: () => _zap(a), child: Text('$a msats')))
                  .toList(),
            ),
            const SizedBox(height: 12),
            Text(status, key: const Key('zap-status')),
          ],
        ),
      ),
    );
  }
}
