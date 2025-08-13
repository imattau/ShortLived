import 'package:flutter/material.dart';

class OverlayCluster extends StatelessWidget {
  const OverlayCluster({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Stack(
        children: [
          // Top-left glyph (long-press later to open Relays sheet)
          Positioned(
            left: 12, top: 8,
            child: IconButton(
              icon: const Icon(Icons.blur_on),
              tooltip: 'App',
              onPressed: () {},
            ),
          ),
          // Top-right search
          Positioned(
            right: 12, top: 8,
            child: IconButton(
              icon: const Icon(Icons.search),
              tooltip: 'Search',
              onPressed: () {},
            ),
          ),
          // Centre-right action rail
          Positioned.fill(
            child: Align(
              alignment: Alignment.centerRight,
              child: Padding(
                padding: const EdgeInsets.only(right: 8),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(icon: const Icon(Icons.favorite_border), onPressed: () {}),
                    IconButton(icon: const Icon(Icons.chat_bubble_outline), onPressed: () {}),
                    IconButton(icon: const Icon(Icons.bolt_outlined), onPressed: () {}),
                    IconButton(icon: const Icon(Icons.ios_share), onPressed: () {}),
                    IconButton(icon: const Icon(Icons.person_outline), onPressed: () {}),
                  ],
                ),
              ),
            ),
          ),
          // Bottom-left author + caption
          Positioned(
            left: 12, right: 96, bottom: 84,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text('@author', style: TextStyle(fontWeight: FontWeight.bold)),
                SizedBox(height: 6),
                Text('Caption goes here #tags', maxLines: 2, overflow: TextOverflow.ellipsis),
              ],
            ),
          ),
          // Bottom-centre Create FAB
          Positioned(
            left: 0, right: 0, bottom: 16,
            child: Center(
              child: FloatingActionButton.large(
                onPressed: () {},
                child: const Icon(Icons.add),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
