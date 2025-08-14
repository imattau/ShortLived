import 'package:flutter/material.dart';
import '../../services/nostr/relay_service.dart';

class QuoteSheet extends StatefulWidget {
  const QuoteSheet({super.key, required this.eventId, required this.relay});
  final String eventId;
  final RelayService relay;

  @override
  State<QuoteSheet> createState() => _QuoteSheetState();
}

class _QuoteSheetState extends State<QuoteSheet> {
  final TextEditingController _ctrl = TextEditingController();
  bool sending = false;

  Future<void> _send() async {
    if (_ctrl.text.trim().isEmpty || sending) return;
    setState(() => sending = true);
    try {
      await (widget.relay as dynamic)
          .quote(eventId: widget.eventId, content: _ctrl.text.trim());
      if (mounted) Navigator.of(context).maybePop();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Failed: $e')));
      }
    } finally {
      if (mounted) setState(() => sending = false);
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
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            TextField(
              controller: _ctrl,
              minLines: 2,
              maxLines: 6,
              decoration: const InputDecoration(hintText: 'Add your thoughts'),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: sending ? null : _send,
                child: sending
                    ? const CircularProgressIndicator()
                    : const Text('Post quote'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
