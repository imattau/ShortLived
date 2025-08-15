import '../nostr/relay_service.dart';
import '../keys/key_service.dart';
import '../../crypto/nostr_event.dart';
import '../settings/settings_service.dart';
import 'mute_models.dart';

class MuteService {
  final SettingsService settings;
  final RelayService relay;
  final KeyService keys;
  MuteList _list;

  MuteService(this.settings, this.relay, this.keys)
      : _list = settings.loadMuteList();

  MuteList current() => _list;

  Future<void> muteUser(String pubkey) async {
    _list = _list.copyWith(users: {..._list.users, pubkey});
    await _persistAndPublish();
  }

  Future<void> unmuteUser(String pubkey) async {
    final s = {..._list.users}..remove(pubkey);
    _list = _list.copyWith(users: s);
    await _persistAndPublish();
  }

  Future<void> muteEvent(String id) async {
    _list = _list.copyWith(events: {..._list.events, id});
    await _persistAndPublish();
  }

  Future<void> unmuteEvent(String id) async {
    final s = {..._list.events}..remove(id);
    _list = _list.copyWith(events: s);
    await _persistAndPublish();
  }

  Future<void> muteTag(String tag) async {
    _list = _list.copyWith(tags: {..._list.tags, tag.toLowerCase()});
    await _persistAndPublish();
  }

  Future<void> unmuteTag(String tag) async {
    final s = {..._list.tags}..remove(tag.toLowerCase());
    _list = _list.copyWith(tags: s);
    await _persistAndPublish();
  }

  Future<void> muteWord(String w) async {
    _list = _list.copyWith(words: {..._list.words, w.toLowerCase()});
    await _persistAndPublish();
  }

  Future<void> unmuteWord(String w) async {
    final s = {..._list.words}..remove(w.toLowerCase());
    _list = _list.copyWith(words: s);
    await _persistAndPublish();
  }

  bool isPostMuted({required String author, required String eventId, required String caption}) {
    if (_list.users.contains(author)) return true;
    if (_list.events.contains(eventId)) return true;
    final low = caption.toLowerCase();
    for (final t in _list.tags) {
      if (RegExp(r'(?:^|\s)#' + RegExp.escape(t) + r'(?:\s|$)').hasMatch(low)) {
        return true;
      }
    }
    for (final w in _list.words) {
      if (
          RegExp(r'(^|\s)' + RegExp.escape(w) + r'\w*(\s|$)').hasMatch(low)) {
        return true;
      }
    }
    return false;
  }

  Future<void> _persistAndPublish() async {
    await settings.saveMuteList(_list);
    await _publishKind10000();
  }

  Future<void> _publishKind10000() async {
    final priv = await keys.getPrivkey();
    final pub = await keys.getPubkey();
    if (priv == null || pub == null) return;
    final now = DateTime.now().millisecondsSinceEpoch ~/ 1000;

    final tags = <List<String>>[
      for (final pk in _list.users) ['p', pk],
      for (final id in _list.events) ['e', id],
      for (final t in _list.tags) ['t', t],
      for (final w in _list.words) ['word', w],
    ];

    final e = NostrEvent(kind: 10000, createdAt: now, content: '', tags: tags);
    final signed = NostrEvent.sign(priv, pub, e);
    await relay.publishEvent(signed);
  }
}
