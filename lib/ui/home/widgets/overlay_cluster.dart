import 'package:flutter/material.dart';

class OverlayCluster extends StatelessWidget {
  const OverlayCluster({super.key, required this.onCreate});
  final VoidCallback onCreate;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned(
          left: 16,
          top: 16,
          child: Icon(Icons.movie, semanticLabel: 'App'),
        ),
        Positioned(
          right: 16,
          top: 16,
          child: Icon(Icons.search, semanticLabel: 'Search'),
        ),
        Positioned(
          right: 16,
          bottom: MediaQuery.of(context).size.height / 2 - 44,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: const [
              Icon(Icons.favorite, size: 44, semanticLabel: 'Like'),
              SizedBox(height: 8),
              Icon(Icons.comment, size: 44, semanticLabel: 'Comment'),
              SizedBox(height: 8),
              Icon(Icons.flash_on, size: 44, semanticLabel: 'Zap'),
              SizedBox(height: 8),
              Icon(Icons.share, size: 44, semanticLabel: 'Share'),
              SizedBox(height: 8),
              Icon(Icons.account_circle, size: 44, semanticLabel: 'Profile'),
            ],
          ),
        ),
        Positioned(
          left: 16,
          bottom: 100,
          right: 16,
          child: Row(
            children: const [
              CircleAvatar(),
              SizedBox(width: 8),
              Expanded(child: Text('Caption', maxLines: 2, overflow: TextOverflow.ellipsis)),
            ],
          ),
        ),
        Positioned(
          bottom: 16,
          left: 0,
          right: 0,
          child: Center(
            child: FloatingActionButton(
              onPressed: onCreate,
              child: const Icon(Icons.add),
            ),
          ),
        ),
      ],
    );
  }
}
