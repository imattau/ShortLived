import 'package:flutter/material.dart';

class SearchDrawer extends StatelessWidget {
  final VoidCallback? onClose;
  const SearchDrawer({super.key, this.onClose});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Container(
        width: 360,
        height: double.infinity,
        decoration: const BoxDecoration(
          color: Color(0xFF111111),
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(16),
            bottomLeft: Radius.circular(16),
          ),
        ),
        child: SafeArea(
          left: false,
          right: false,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(12, 8, 8, 8),
                child: Row(
                  children: [
                    const Expanded(
                      child: Text('Search',
                          style: TextStyle(color: Colors.white, fontSize: 18)),
                    ),
                    IconButton(
                      tooltip: 'Close',
                      splashRadius: 18,
                      icon: const Icon(Icons.close, color: Colors.white70),
                      onPressed: onClose ?? () => Navigator.maybePop(context),
                    ),
                  ],
                ),
              ),
              const Divider(height: 1, color: Colors.white12),
              // … existing search content …
            ],
          ),
        ),
      ),
    );
  }
}
