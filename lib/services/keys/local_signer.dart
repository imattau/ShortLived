import '../../crypto/nostr_event.dart';
import 'signer.dart';
import 'key_service.dart';

class LocalSigner implements Signer {
  final KeyService keys;
  LocalSigner(this.keys);

  @override
  Future<String?> getPubkey() => keys.getPubkey();

  @override
  Future<Map<String, dynamic>?> sign(int kind, String content, List<List<String>> tags) async {
    final priv = await keys.getPrivkey();
    final pub = await keys.getPubkey();
    if (priv == null || pub == null) return null;
    final now = DateTime.now().millisecondsSinceEpoch ~/ 1000;
    final e = NostrEvent(kind: kind, createdAt: now, content: content, tags: tags);
    return NostrEvent.sign(priv, pub, e);
  }
}
