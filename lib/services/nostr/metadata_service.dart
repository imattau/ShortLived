import 'dart:async';
import 'dart:convert';

class AuthorMeta {
  final String pubkey;
  final String name;
  final String picture;
  final String? lud16; // name@domain
  final String? lud06; // bech32 lnurl
  const AuthorMeta(this.pubkey, this.name, this.picture, {this.lud16, this.lud06});
}

class MetadataService {
  final _byPk = <String, AuthorMeta>{};
  final _ctrl = StreamController<AuthorMeta>.broadcast();
  Stream<AuthorMeta> get stream => _ctrl.stream;

  AuthorMeta? get(String pubkey) => _byPk[pubkey];

  void handleEvent(Map<String, dynamic> evt) {
    if (evt['kind'] != 0) return;
    final pk = (evt['pubkey'] ?? '') as String;
    try {
      final m = jsonDecode((evt['content'] ?? '{}') as String) as Map<String, dynamic>;
      final name = (m['name'] ?? m['display_name'] ?? pk.substring(0, 8)).toString();
      final pic = (m['picture'] ?? '').toString();
      final meta = AuthorMeta(
        pk,
        name,
        pic,
        lud16: (m['lud16'] ?? '') as String? ?? '',
        lud06: (m['lud06'] ?? '') as String? ?? '',
      );
      _byPk[pk] = meta;
      _ctrl.add(meta);
    } catch (_) {}
  }
}
