import 'package:flutter/material.dart';

class OverlayCluster extends StatelessWidget {
  const OverlayCluster({
    super.key,
    required this.onCreateTap,
    required this.onLikeTap,
    required this.onCommentTap,
    required this.onRepostTap,
    required this.onQuoteTap,
    required this.onZapTap,
    required this.onProfileTap,
    required this.onDetailsTap,
    required this.onRelaysLongPress,
    required this.onSearchTap,
    required this.onSettingsTap,
    required this.safetyOn,
    required this.onSafetyToggle,
    required this.onShareTap,
    this.showInstall = false,
    this.onInstallTap,
  });
  final VoidCallback onCreateTap;
  final VoidCallback onLikeTap;
  final VoidCallback onCommentTap;
  final VoidCallback onRepostTap;
  final VoidCallback onQuoteTap;
  final VoidCallback onZapTap;
  final VoidCallback onProfileTap;
  final VoidCallback onDetailsTap;
  final VoidCallback onRelaysLongPress;
  final VoidCallback onSearchTap;
  final VoidCallback onSettingsTap;
  final bool safetyOn;
  final VoidCallback onSafetyToggle;
  final VoidCallback onShareTap;
  final bool showInstall;
  final VoidCallback? onInstallTap;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Stack(
        children: [
          Positioned(
            top: 8,
            left: 8,
            child: AnimatedOpacity(
              duration: const Duration(milliseconds: 200),
              opacity: showInstall ? 1 : 0,
              child: ActionChip(
                label: const Text('Install app'),
                onPressed: onInstallTap,
              ),
            ),
          ),
          // Top-left glyph (long-press later to open Relays sheet)
          Positioned(
            left: 12,
            top: 8,
            child: GestureDetector(
              onLongPress: onRelaysLongPress,
              child: IconButton(
                icon: const Icon(Icons.blur_on),
                tooltip: 'App',
                onPressed: onSettingsTap,
              ),
            ),
          ),
          // Top-right search
          Positioned(
            right: 12,
            top: 8,
            child: IconButton(
              icon: const Icon(Icons.search),
              tooltip: 'Search',
              onPressed: onSearchTap,
            ),
          ),
          Positioned(
            right: 12,
            top: 8 + 28,
            child: IconButton(
              tooltip: 'Safety mode',
              icon: Icon(safetyOn ? Icons.shield : Icons.shield_outlined),
              onPressed: onSafetyToggle,
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
                    IconButton(
                      icon: const Icon(Icons.favorite_border),
                      onPressed: onLikeTap,
                    ),
                    IconButton(
                      icon: const Icon(Icons.chat_bubble_outline),
                      onPressed: onCommentTap,
                    ),
                  GestureDetector(
                    onLongPress: onQuoteTap,
                    child: IconButton(
                      icon: const Icon(Icons.repeat),
                      onPressed: onRepostTap,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.bolt_outlined),
                    onPressed: onZapTap,
                  ),
                  IconButton(
                    icon: const Icon(Icons.ios_share),
                    onPressed: onShareTap,
                  ),
                ],
              ),
            ),
          ),
          ),
          // Bottom-left author + caption
          Positioned(
            left: 12,
            right: 96,
            bottom: 84,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                GestureDetector(
                  onTap: onProfileTap,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: const [
                      CircleAvatar(radius: 12, child: Text('A')),
                      SizedBox(width: 8),
                      Text(
                        '@author',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 6),
                GestureDetector(
                  onTap: onDetailsTap,
                  child: const Text(
                    'Caption goes here #tags',
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
          // Bottom-centre Create FAB
          Positioned(
            left: 0,
            right: 0,
            bottom: 16,
            child: Center(
              child: FloatingActionButton.large(
                onPressed: onCreateTap,
                child: const Icon(Icons.add),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
