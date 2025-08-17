import 'package:flutter/material.dart';

class UnsupportedOverlay extends StatelessWidget {
  final String message;
  final VoidCallback? onSkip;
  const UnsupportedOverlay({super.key, required this.message, this.onSkip});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.bottomLeft,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.55),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(message, style: const TextStyle(color: Colors.white)),
            ),
            const SizedBox(width: 8),
            TextButton(
              onPressed: onSkip,
              child: const Text('Skip'),
            ),
          ],
        ),
      ),
    );
  }
}
