import 'package:flutter/material.dart';

/// Simple wrapper to map string-based asset names to [IconData].
class AppIcon extends StatelessWidget {
  final String name;
  const AppIcon(this.name, {super.key});

  @override
  Widget build(BuildContext context) {
    IconData icon;
    switch (name) {
      case 'bell_24':
        icon = Icons.notifications;
        break;
      default:
        icon = Icons.circle;
    }
    return Icon(icon);
  }
}
