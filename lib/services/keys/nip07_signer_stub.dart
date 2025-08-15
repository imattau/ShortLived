import 'signer.dart';

class Nip07Signer implements Signer {
  bool get available => false;
  @override
  Future<String?> getPubkey() async => null;
  @override
  Future<Map<String, dynamic>?> sign(
          int kind, String content, List<List<String>> tags) async =>
      null;
}
