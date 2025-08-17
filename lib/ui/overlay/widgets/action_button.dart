import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
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

  double _btnSize(BuildContext context) {
    // On the web with a mouse, allow 40px; otherwise 44px for touch.
    final kind = RendererBinding.instance.mouseTracker.mouseIsConnected;
    return kind ? T.btnSizeMouse : T.btnSizeTouch;
  }

  @override
  Widget build(BuildContext context) {
    final size = _btnSize(context);

    final core = Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        InkResponse(
          onTap: onTap,
          radius: size / 2,
          child: SizedBox(
            width: size,
            height: size,
            child: Center(child: AppIcon(icon, size: 24, color: color)),
          ),
        ),
        if (label != null) ...[
          const SizedBox(width: T.rowGap),
          SizedBox(
            width: 28,
            child: Text(
              label!,
              maxLines: 1,
              overflow: TextOverflow.fade,
              softWrap: false,
              textAlign: TextAlign.right,
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    fontSize: 11,
                    height: 1.0,
                    color: color.withValues(alpha: 0.9),
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.1,
                  ),
            ),
          ),
        ],
      ],
    );

    return (kIsWeb && tooltip != null)
        ? Tooltip(message: tooltip!, child: core)
        : core;
  }
}

