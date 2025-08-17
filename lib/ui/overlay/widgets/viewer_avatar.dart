import 'package:flutter/material.dart';
import '../../../session/user_session.dart';
import '../sheet_gate.dart';
import 'account_menu.dart';

class ViewerAvatar extends StatelessWidget {
  final double size;
  const ViewerAvatar({super.key, this.size = 44});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<UserProfile?>(
      valueListenable: userSession.current,
      builder: (_, p, __) {
        final url = p?.pictureUrl;
        final initials = _initials(p?.displayName ?? p?.npub ?? '');
        final bg = _seedColor(p?.npub ?? 'guest');

        final avatar = ClipOval(
          child: Container(
            width: size,
            height: size,
            color: bg,
            child: url != null && url.isNotEmpty
                ? Image.network(
                    url,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) {
                      return _fallback(initials);
                    },
                  )
                : _fallback(initials),
          ),
        );

        return Material(
          color: Colors.transparent,
          child: InkWell(
            customBorder: const CircleBorder(),
            onTap: () =>
                SheetGate.toggleAccountMenu(context, accountMenuContent),
            child: avatar,
          ),
        );
      },
    );
  }

  Widget _fallback(String initials) => Center(
        child: Text(
          initials,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w700,
          ),
        ),
      );

  String _initials(String s) {
    final parts = s.trim().split(RegExp(r'\s+'));
    if (parts.isEmpty) return 'U';
    final a = parts.first.isNotEmpty ? parts.first[0] : 'U';
    final b = parts.length > 1 && parts.last.isNotEmpty ? parts.last[0] : '';
    return (a + b).toUpperCase();
  }

  Color _seedColor(String seed) {
    final h = seed.codeUnits.fold<int>(0, (a, b) => (a + b) & 0xFF);
    final hue = (h * 3.6) % 360; // 0..360
    return HSLColor.fromAHSL(1, hue, 0.55, 0.45).toColor();
  }
}
