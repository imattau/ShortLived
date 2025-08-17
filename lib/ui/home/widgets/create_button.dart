import 'package:flutter/material.dart';

/// Simple placeholder "Create" button used as floating action button.
class CreateButton extends StatelessWidget {
  const CreateButton({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(28),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.85),
                width: 2,
              ),
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Create',
            style: TextStyle(color: Colors.white),
          ),
        ],
      ),
    );
  }
}

