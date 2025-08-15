import 'dart:async';
import '../keys/key_service.dart';
import '../nostr/relay_service.dart';
import '../settings/settings_service.dart';

class RelayEntry {
  final Uri uri;
  final bool read;
  final bool write;
  const RelayEntry(this.uri, {this.read = true, this.write = true});

  RelayEntry copyWith({bool? read, bool? write}) =>
      RelayEntry(uri, read: read ?? this.read, write: write ?? this.write);
}

  class RelayDirectory {
    RelayDirectory(this._settings, this._relay, this._keys);
    final SettingsService _settings;
    final RelayService _relay;
    final KeyService _keys;

  List<RelayEntry> _list = [];

  List<RelayEntry> current() => List.unmodifiable(_list);

  /// Load local settings; then attempt remote import (kind:10002).
  Future<void> init() async {
    _list = _settings.loadRelays();
    // Try pull remote list; if newer, replace local and persist.
    final remote = await _fetchRemote();
    if (remote != null) {
      final remoteAt = remote.$2; // created_at
      final localAt = _settings.relaysUpdatedAt();
      if (remoteAt > localAt) {
        _list = remote.$1;
        await _settings.saveRelays(_list, updatedAt: remoteAt);
      }
    }
    await _applyToRelay();
  }

  Future<void> add(String url, {bool read = true, bool write = true}) async {
    final uri = Uri.parse(url);
    if (_list.any((e) => e.uri == uri)) return;
    _list = [..._list, RelayEntry(uri, read: read, write: write)];
    await _persistAndPublish();
  }

  Future<void> remove(String url) async {
    final uri = Uri.parse(url);
    _list = _list.where((e) => e.uri != uri).toList();
    await _persistAndPublish();
  }

  Future<void> setFlags(String url, {bool? read, bool? write}) async {
    final uri = Uri.parse(url);
    _list = _list
        .map((e) => e.uri == uri ? e.copyWith(read: read, write: write) : e)
        .toList();
    await _persistAndPublish();
  }

  Future<void> _persistAndPublish() async {
    final now = DateTime.now().millisecondsSinceEpoch ~/ 1000;
    await _settings.saveRelays(_list, updatedAt: now);
    await _publishKind10002(now);
    await _applyToRelay();
  }

  Future<void> _applyToRelay() async {
    final urls = _list
        .where((e) => e.read || e.write)
        .map((e) => e.uri.toString())
        .toList();
    if (urls.isEmpty) return;
    await _relay.resetConnections(urls); // new method added below
  }

  /// Fetch remote kind:10002 for the current user; returns (list, created_at) or null.
  Future<(List<RelayEntry>, int)?> _fetchRemote() async {
    final pub = await _keys.getPubkey();
    if (pub == null || pub.isEmpty) return null;
    // Subscribe once for kind:10002 authored by pub; close after first EVENT or EOSE
    final subId = await _relay.subscribe([
      {
        "kinds": [10002],
        "authors": [pub],
        "limit": 1,
      }
    ], subId: "nip65_self");

    final completer = Completer<(List<RelayEntry>, int)?>();
    late final StreamSubscription sub;
    sub = _relay.events.listen((evt) {
      if ((evt['kind'] as int?) == 10002 && (evt['pubkey'] as String?) == pub) {
        final created = (evt['created_at'] ?? 0) as int;
        final tags =
            (evt['tags'] as List?)?.whereType<List>().toList() ?? const [];
        final list = <RelayEntry>[];
        for (final t in tags) {
          if (t.isEmpty || t.first != 'r') continue;
          final url = (t.length >= 2) ? t[1] as String : '';
          if (url.isEmpty) continue;
          final marker = (t.length >= 3) ? (t[2] as String).toLowerCase() : '';
          final read = marker.isEmpty || marker == 'read' || marker == 'both';
          final write = marker.isEmpty || marker == 'write' || marker == 'both';
          list.add(RelayEntry(Uri.parse(url), read: read, write: write));
        }
        completer.complete((list, created));
        sub.cancel();
      }
    }, onDone: () {
      completer.complete(null);
    }, onError: (_) {
      completer.complete(null);
    });

    // Failsafe timeout
    Future.delayed(const Duration(seconds: 2)).then((_) {
      if (!completer.isCompleted) {
        sub.cancel();
        completer.complete(null);
      }
    });

    final res = await completer.future;
    await _relay.close(subId);
    return res;
  }

  Future<void> _publishKind10002(int createdAt) async {
    final tags = <List<String>>[
      for (final e in _list)
        if (e.read && e.write)
          ['r', e.uri.toString()]
        else if (e.read && !e.write)
          ['r', e.uri.toString(), 'read']
        else if (!e.read && e.write)
          ['r', e.uri.toString(), 'write']
        else
          ...[]
    ];
    await _relay.signAndPublish(kind: 10002, content: '', tags: tags);
  }
}
