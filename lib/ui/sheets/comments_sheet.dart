import 'package:flutter/material.dart';
import '../../services/nostr/relay_service.dart';

class CommentsSheet extends StatefulWidget {
  const CommentsSheet(
      {super.key,
      required this.parentEventId,
      this.parentPubkey,
      required this.relay});
  final String parentEventId;
  final String? parentPubkey;
  final RelayService relay;

  @override
  State<CommentsSheet> createState() => _CommentsSheetState();
}

class _CommentsSheetState extends State<CommentsSheet> {
  final TextEditingController _ctrl = TextEditingController();
  bool sending = false;

  Future<void> _send() async {
    if (_ctrl.text.trim().isEmpty || sending) return;
    setState(() => sending = true);
    try {
      await widget.relay.reply(
          parentId: widget.parentEventId,
          content: _ctrl.text.trim(),
          parentPubkey: widget.parentPubkey);
      _ctrl.clear();
      if (mounted) Navigator.of(context).maybePop();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Failed to send: $e')));
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
                    borderRadius: BorderRadius.circular(2))),
            TextField(
                controller: _ctrl,
                minLines: 1,
                maxLines: 5,
                decoration: const InputDecoration(hintText: 'Add a comment')),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                  onPressed: sending ? null : _send,
                  child: sending
                      ? const CircularProgressIndicator()
                      : const Text('Send')),
            ),
          ],
        ),
      ),
    );
  }
}
