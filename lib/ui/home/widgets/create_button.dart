import 'package:flutter/material.dart';

/// Floating "Create" button used on the home page.
class CreateButton extends StatelessWidget {
  const CreateButton({
    super.key,
    required this.onPressed,
    this.hidden = false,
  });

  final VoidCallback onPressed;
  final bool hidden;

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      ignoring: hidden,
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 180),
        opacity: hidden ? 0.0 : 1.0,
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            shape: const CircleBorder(),
            padding: const EdgeInsets.all(22),
          ),
          onPressed: onPressed,
          child: const Icon(Icons.add),
        ),
      ),
    );
  }
}

