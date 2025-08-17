import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:vector_graphics/vector_graphics.dart';

class AppIcon extends StatelessWidget {
  final String name;
  final double size;
  final Color? color;
  const AppIcon(this.name, {super.key, this.size = 24, this.color});

  static const _base = 'assets/icons';

  static final Map<String, IconData> _fallback = {
    'heart_24': Icons.favorite_border,
    'comment_24': Icons.mode_comment_outlined,
    'repost_24': Icons.cached,
    'share_24': Icons.ios_share,
    'bookmark_24': Icons.bookmark_border,
    'bell_24': Icons.notifications_none,
    'copy_24': Icons.copy_all_outlined,
    'zap_24': Icons.bolt_outlined,
    'search_24': Icons.search,
  };

  Future<bool> _vecExists(String p) async {
    try {
      await rootBundle.load(p);
      return true;
    } catch (_) {
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final p = '$_base/$name.svg.vec';
    return FutureBuilder<bool>(
      future: _vecExists(p),
      builder: (context, snap) {
        if (snap.data == true) {
          return VectorGraphic(
            loader: AssetBytesLoader(p),
            width: size,
            height: size,
            colorFilter:
                ColorFilter.mode(color ?? Colors.white, BlendMode.srcIn),
          );
        }
        final ico = _fallback[name];
        if (ico != null) {
          return Icon(ico, size: size, color: color ?? Colors.white);
        }
        return SizedBox(width: size, height: size);
      },
    );
  }
}

