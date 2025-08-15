import 'package:flutter/material.dart';
import '../../core/di/locator.dart';
import '../../data/models/post.dart';
import '../../state/feed_controller.dart';
import '../../services/nostr/relay_service.dart';
import '../../services/nostr/metadata_service.dart';
import '../../data/repos/thread_repository.dart';

class CommentsSheet extends StatefulWidget {
  const CommentsSheet({super.key, required this.post});
  final Post post;

  @override
  State<CommentsSheet> createState() => _CommentsSheetState();
}

class _CommentsSheetState extends State<CommentsSheet> {
  final _ctrl = TextEditingController();
  final _scroll = ScrollController();
  ThreadRepository? _repo;
  List<ThreadComment> _comments = [];
  bool _sending = false;

  @override
  void initState() {
    super.initState();
    final relay = Locator.I.get<RelayService>();
    final meta = Locator.I.get<MetadataService>();
    _repo = ThreadRepository(relay, meta);
    _repo!.watchThread(rootEventId: widget.post.id).listen((list) {
      if (mounted) setState(() => _comments = list);
    });
  }

  @override
  void dispose() {
    _ctrl.dispose();
    _scroll.dispose();
    _repo?.dispose();
    super.dispose();
  }

  Future<void> _send() async {
    final text = _ctrl.text.trim();
    if (text.isEmpty || _sending) return;
    setState(() => _sending = true);

    try {
      // Optimistic increment on the feed model
      final fc = Locator.I.get<FeedController>();
      final idx = fc.posts.indexWhere((p) => p.id == widget.post.id);
      if (idx >= 0) {
        final p = fc.posts[idx];
        fc.posts[idx] = p.copyWith(commentCount: p.commentCount + 1);
        fc.refresh();
      }

      await Locator.I.get<RelayService>().reply(
        parentId: widget.post.id,
        parentPubkey: widget.post.author.pubkey,
        content: text,
        rootId: widget.post.id,
        rootPubkey: widget.post.author.pubkey,
      );

      _ctrl.clear();
      // Scroll to bottom after a short delay so the layout settles
      await Future<void>.delayed(const Duration(milliseconds: 50));
      if (mounted && _scroll.hasClients) {
        _scroll.animateTo(_scroll.position.maxScrollExtent,
            duration: const Duration(milliseconds: 180),
            curve: Curves.easeOut);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Failed to send: $e')));
      }
    } finally {
      if (mounted) setState(() => _sending = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final meta =
        Locator.I.tryGet<MetadataService>()?.get(widget.post.author.pubkey);
    final who = meta?.name ?? widget.post.author.name;

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
                height: 4,
                width: 36,
                margin: const EdgeInsets.only(bottom: 12),
                decoration: BoxDecoration(
                    color: Colors.white24,
                    borderRadius: BorderRadius.circular(2))),
            Align(
                alignment: Alignment.centerLeft,
                child: Text('Comments • $who',
                    style: const TextStyle(fontWeight: FontWeight.bold))),
            const SizedBox(height: 8),
            Flexible(
              child: ListView.builder(
                controller: _scroll,
                shrinkWrap: true,
                itemCount: _comments.length,
                itemBuilder: (_, i) {
                  final c = _comments[i];
                  return ListTile(
                    dense: true,
                    leading: CircleAvatar(
                        backgroundImage: (c.authorAvatar.isNotEmpty)
                            ? NetworkImage(c.authorAvatar)
                            : null,
                        child: (c.authorAvatar.isEmpty)
                            ? Text(c.authorName.substring(0, 1))
                            : null),
                    title: Text(c.authorName,
                        style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text(c.content),
                  );
                },
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                    child: TextField(
                        controller: _ctrl,
                        decoration:
                            const InputDecoration(hintText: 'Add a comment…'),
                        minLines: 1,
                        maxLines: 4)),
                const SizedBox(width: 8),
                ElevatedButton(
                    onPressed: _sending ? null : _send,
                    child: const Text('Send')),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
