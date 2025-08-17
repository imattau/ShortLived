import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../../design/tokens.dart';
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
    final core = Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        InkResponse(
          onTap: onTap,
          radius: T.btnSize / 2,
          child: SizedBox(
            width: T.btnSize,
            height: T.btnSize,
            child: Center(child: AppIcon(icon, size: 24, color: color)),
          ),
        ),
        if (label != null) ...[
          const SizedBox(height: T.btnGap),
          Text(
            label!,
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
              fontSize: 11,
              height: 1.0,
              color: color.withOpacity(0.85),
              fontWeight: FontWeight.w600,
              letterSpacing: 0.15,
            ),
          ),
        ],
      ],
    );

    // Tooltips are most useful on web/desktop.
    return kIsWeb && tooltip != null
        ? Tooltip(
            message: tooltip!,
            waitDuration: const Duration(milliseconds: 300),
            child: core,
          )
        : core;
  }
}
