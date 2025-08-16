import 'dart:math';
import 'package:flutter/material.dart';
import '../../design/tokens.dart';
import '../hud_model.dart';

class BottomInfoBar extends StatelessWidget {
  final HudModel model;
  const BottomInfoBar({super.key, required this.model});

  String _short(String s) {
    if (s.length <= 14) return s;
    return '${s.substring(0, 6)}…${s.substring(s.length - 6)}';
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final maxW = min(size.width * 0.78, 520.0);
    final showMore = model.fullCaption.trim() != model.caption.trim();

    return ConstrainedBox(
      constraints: BoxConstraints(maxWidth: maxW),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Author row
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withOpacity(0.15),
                ),
                child: const Icon(Icons.person, size: 18, color: Colors.white),
              ),
              const SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    model.authorDisplay,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                  Text(
                    _short(model.authorNpub),
                    style: const TextStyle(color: Colors.white70, fontSize: 11),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 10),
          // Caption (clamped to 3 lines with fade)
          Stack(
            children: [
              ClipRect(
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.30),
                    borderRadius: BorderRadius.circular(T.r16),
                  ),
                  child: Text(
                    model.caption,
                    maxLines: 3,
                    overflow: TextOverflow.fade,
                    softWrap: true,
                    style: Theme.of(context)
                        .textTheme
                        .bodyMedium
                        ?.copyWith(color: Colors.white, height: 1.25),
                  ),
                ),
              ),
              if (showMore)
                Positioned(
                  right: 8,
                  bottom: 8,
                  child: TextButton(
                    style: TextButton.styleFrom(
                      foregroundColor: Colors.white,
                      backgroundColor: Colors.black.withOpacity(0.35),
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    onPressed: () => _openFullCaption(context, model),
                    child: const Text('More'),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  void _openFullCaption(BuildContext context, HudModel m) {
    showModalBottomSheet(
      context: context,
      useRootNavigator: true,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF0E0E11),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) => DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.6,
        maxChildSize: 0.9,
        builder: (_, controller) => Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
          child: ListView(
            controller: controller,
            children: [
              Row(
                children: [
                  const Icon(Icons.person, color: Colors.white70, size: 18),
                  const SizedBox(width: 8),
                  Text(m.authorDisplay, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
                  const SizedBox(width: 8),
                  Text(_short(m.authorNpub), style: const TextStyle(color: Colors.white54, fontSize: 12)),
                ],
              ),
              const SizedBox(height: 12),
              SelectableText(
                m.fullCaption,
                style: const TextStyle(color: Colors.white, height: 1.35),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

