import 'dart:ui';
import 'package:flutter/material.dart';

class BlurShield extends StatelessWidget {
  const BlurShield({super.key, required this.visible, required this.onReveal});
  final bool visible;
  final VoidCallback onReveal;

  @override
  Widget build(BuildContext context) {
    if (!visible) return const SizedBox.shrink();
    return Stack(
      fit: StackFit.expand,
      children: [
        Positioned.fill(
          child: ClipRect(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
              child: Container(color: Colors.black.withValues(alpha: 0.35)),
            ),
          ),
        ),
        Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.shield, size: 40, color: Colors.white),
              const SizedBox(height: 8),
              const Text(
                'Sensitive — tap to reveal',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              ElevatedButton(
                onPressed: onReveal,
                child: const Text('Reveal once'),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
