import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../../widgets/app_icon.dart';

class ActionButton extends StatelessWidget {
  final String icon; // e.g. 'heart_24'
  final String? label; // numeric count
  final VoidCallback? onTap;
  final String? tooltip;
  final Color color;

  const ActionButton({
    super.key,
    required this.icon,
    this.label,
    this.onTap,
    this.tooltip,
    this.color = Colors.white,
  });

  @override
  Widget build(BuildContext context) {
    final hasLabel = label != null && label!.isNotEmpty;
    final textStyle = Theme.of(context).textTheme.labelSmall?.copyWith(
          color: Colors.white60,
          height: 1.1,
          fontWeight: FontWeight.w500,
        );

    final core = InkResponse(
      onTap: onTap,
      radius: 28,
      containedInkWell: true,
      child: SizedBox(
        width: 44,
        height: 44,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            AppIcon(icon, size: 24, color: color),
            if (hasLabel) ...[
              const SizedBox(height: 4),
              SizedBox(
                height: 16,
                child: Text(
                  label!,
                  maxLines: 1,
                  textAlign: TextAlign.center,
                  overflow: TextOverflow.clip,
                  style: textStyle,
                ),
              ),
            ],
          ],
        ),
      ),
    );

    return (kIsWeb && tooltip != null)
        ? Tooltip(message: tooltip!, child: core)
        : core;
  }
}

