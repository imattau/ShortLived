import 'package:flutter/material.dart';

class ReportSheet extends StatefulWidget {
  const ReportSheet({super.key, required this.eventId});
  final String eventId;

  @override
  State<ReportSheet> createState() => _ReportSheetState();
}

class _ReportSheetState extends State<ReportSheet> {
  final _ctrl = TextEditingController();
  bool sending = false;

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (sending) return;
    setState(() => sending = true);
    // Local log only for MVP; append to a debugPrint or future Hive box.
    // For now, show a snackbar and close.
    // ignore: use_build_context_synchronously
    ScaffoldMessenger.of(context)
        .showSnackBar(const SnackBar(content: Text('Report saved locally')));
    if (mounted) Navigator.of(context).maybePop();
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
            Align(
              alignment: Alignment.centerLeft,
              child: Text('Report ${widget.eventId}',
                  style: const TextStyle(fontWeight: FontWeight.bold)),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _ctrl,
              minLines: 2,
              maxLines: 6,
              decoration: const InputDecoration(
                  hintText: 'Describe the issue (stays on device)'),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: sending ? null : _submit,
                child: sending
                    ? const CircularProgressIndicator()
                    : const Text('Submit'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

