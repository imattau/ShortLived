import 'package:flutter/material.dart';

/// Bottom-right floating user avatar that opens the account menu.
class CurrentUserBadge extends StatelessWidget {
  const CurrentUserBadge({
    super.key,
    required this.onTap,
  });

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.only(right: 12, bottom: 12),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            customBorder: const CircleBorder(),
            child: Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: theme.colorScheme.surface.withValues(alpha: 0.85),
                boxShadow: const [
                  BoxShadow(
                    blurRadius: 10,
                    spreadRadius: 2,
                    offset: Offset(0, 2),
                    color: Colors.black26,
                  ),
                ],
              ),
              padding: const EdgeInsets.all(6),
              child: const CircleAvatar(
                radius: 16,
                backgroundColor: Colors.transparent,
                child: Icon(Icons.person_outline),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

