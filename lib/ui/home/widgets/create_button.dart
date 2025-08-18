import 'package:flutter/material.dart';

/// Compact bottom-center "Create" button with ring style.
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
    final isWide = MediaQuery.of(context).size.width >= 720;
    final size = isWide ? 64.0 : 56.0;

    final button = OutlinedButton(
      onPressed: onPressed,
      style: OutlinedButton.styleFrom(
        minimumSize: Size.square(size),
        padding: EdgeInsets.zero,
        shape: const CircleBorder(),
        side: BorderSide(color: Colors.white.withOpacity(.85), width: 1.6),
        backgroundColor: Colors.black.withOpacity(.25),
        foregroundColor: Colors.white,
      ),
      child: Icon(Icons.add, size: isWide ? 28 : 26),
    );

    return AnimatedOpacity(
      duration: const Duration(milliseconds: 180),
      opacity: hidden ? 0 : 1,
      child: IgnorePointer(
        ignoring: hidden,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            button,
            const SizedBox(height: 6),
            const Text(
              'Create',
              style: TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

