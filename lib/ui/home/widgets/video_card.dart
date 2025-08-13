import 'package:flutter/material.dart';
import '../../../data/models/post.dart';

class VideoCard extends StatelessWidget {
  final Post post;
  final bool isCurrent;
  final bool isNeighbour;
  const VideoCard(
      {super.key,
      required this.post,
      required this.isCurrent,
      required this.isNeighbour});

  @override
  Widget build(BuildContext context) {
    // Placeholder for a real video. Show a thumb and basic labels.
    return Stack(
      fit: StackFit.expand,
      children: [
        // In PR 4+, replace with actual video player. For now, coloured box.
        Image.network(post.thumb,
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => Container(color: Colors.black)),
        Align(
          alignment: Alignment.bottomLeft,
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Text(
              '\${post.caption}\n\${isCurrent ? "Playing" : isNeighbour ? "Preloaded" : "Idle"}',
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                  fontSize: 12,
                  color: Colors.white,
                  shadows: [Shadow(blurRadius: 8)]),
            ),
          ),
        ),
      ],
    );
  }
}
