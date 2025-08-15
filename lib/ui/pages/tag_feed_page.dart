import 'package:flutter/material.dart';
import '../../core/di/locator.dart';
import '../../data/models/post.dart';
import '../../state/feed_controller.dart';

class TagFeedPage extends StatefulWidget {
  final String tag; // lowercased, no '#'
  const TagFeedPage({super.key, required this.tag});
  @override
  State<TagFeedPage> createState() => _TagFeedPageState();
}

class _TagFeedPageState extends State<TagFeedPage> {
  List<Post> _items = const [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    // Simple approach: use existing FeedController cache and filter
    final fc = Locator.I.get<FeedController>();
    final cached = fc.posts
        .where((p) =>
            p.caption.toLowerCase().contains('#${widget.tag}'))
        .toList();
    setState(() {
      _items = cached;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('#${widget.tag}')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: _items.length,
              itemBuilder: (_, i) {
                final p = _items[i];
                return ListTile(
                  title: Text(p.author.name),
                  subtitle: Text(p.caption,
                      maxLines: 2, overflow: TextOverflow.ellipsis),
                  onTap: () => Navigator.of(context)
                      .pushNamed('/event', arguments: p.id),
                );
              },
            ),
    );
  }
}
