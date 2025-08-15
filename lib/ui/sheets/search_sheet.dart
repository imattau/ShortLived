import 'package:flutter/material.dart';
import '../../core/di/locator.dart';
import '../../state/feed_controller.dart';
import '../../services/search/search_service.dart';
import '../../services/search/search_models.dart';
import '../../services/nostr/relay_service.dart';
import '../../services/moderation/mute_service.dart';

class SearchSheet extends StatefulWidget {
  const SearchSheet({super.key});
  @override
  State<SearchSheet> createState() => _SearchSheetState();
}

class _SearchSheetState extends State<SearchSheet> {
  final _ctrl = TextEditingController();
  String? _subId;
  List<SearchResultItem> _items = [];
  bool _loading = false;

  @override
  void dispose() {
    _ctrl.dispose();
    final relay = Locator.I.get<RelayService>();
    final sub = _subId;
    if (sub != null) relay.close(sub);
    super.dispose();
  }

  Future<void> _run() async {
    final relay = Locator.I.get<RelayService>();
    final search = SearchService(relay);

    setState(() { _loading = true; _items = []; });

    final q = await search.buildQuery(_ctrl.text);
    final subId = await search.openSubscription(q);
    _subId = subId;

    // Collect results for a short window then render (simple UX)
    final results = <SearchResultItem>[];
    final sub = relay.events.listen((evt) {
      final id = evt['id'] as String?; if (id == null) return;
      final content = (evt['content'] ?? '') as String;
      final pk = (evt['pubkey'] ?? '') as String;
      final title = content.isEmpty ? 'Post $id' : content;
      results.add(SearchResultItem(
        eventId: id,
        title: title.length > 80 ? '${title.substring(0, 80)}…' : title,
        subtitle: '@${pk.substring(0, 8)}',
      ));
      // Coalesce updates
      List<SearchResultItem> items = results.toList();
      final mute = Locator.I.tryGet<MuteService>();
      if (mute != null) {
        items = items.where((it) {
          if (it.eventId.isNotEmpty && mute.current().events.contains(it.eventId)) {
            return false;
          }
          final low = (it.title + ' ' + it.subtitle).toLowerCase();
          for (final w in mute.current().words) {
            if (RegExp(r'(^|\s)' + RegExp.escape(w) + r'(\s|$)').hasMatch(low)) {
              return false;
            }
          }
          for (final t in mute.current().tags) {
            if (low.contains('#$t')) return false;
          }
          return true;
        }).toList();
      }
      if (mounted) setState(() { _items = items; });
    });

    // Close after 1.2s of collection to avoid lingering subs
    await Future<void>.delayed(const Duration(milliseconds: 1200));
    await sub.cancel();
    await relay.close(subId);

    if (mounted) setState(() { _loading = false; });
  }

  @override
  Widget build(BuildContext context) {
    final controller = Locator.I.get<FeedController>();
    final trending = SearchService(Locator.I.get<RelayService>())
        .trendingHashtags(controller.posts);

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(height: 4, width: 36, margin: const EdgeInsets.only(bottom: 12), decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(2))),
            Row(
              children: [
                Expanded(child: TextField(controller: _ctrl, decoration: const InputDecoration(hintText: 'Search #tag, npub… or text'))),
                const SizedBox(width: 8),
                ElevatedButton(onPressed: _loading ? null : _run, child: const Text('Go')),
              ],
            ),
            const SizedBox(height: 12),
            if (trending.isNotEmpty)
              Align(alignment: Alignment.centerLeft, child: Wrap(
                spacing: 8, runSpacing: 8,
                children: trending.map((t) => ActionChip(label: Text('#$t'), onPressed: () { _ctrl.text = '#$t'; _run(); })).toList(),
              )),
            const SizedBox(height: 8),
            if (_loading) const LinearProgressIndicator(minHeight: 2),
            const SizedBox(height: 8),
            Flexible(
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: _items.length,
                itemBuilder: (_, i) {
                  final it = _items[i];
                  return ListTile(
                    dense: true,
                    title: Text(it.title),
                    subtitle: Text(it.subtitle),
                    onTap: () {
                      // Jump feed to the tapped event if it’s in memory; else do nothing for MVP
                      final idx = controller.posts.indexWhere((p) => p.id == it.eventId);
                      if (idx >= 0) {
                        controller.onPageChanged(idx);
                        Navigator.of(context).maybePop();
                      }
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
