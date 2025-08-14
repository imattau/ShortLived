import 'dart:typed_data';

String toHex(dynamic bytesOrHex) {
  if (bytesOrHex is String) return bytesOrHex.toLowerCase();
  final b = (bytesOrHex as List<int>);
  final sb = StringBuffer();
  for (final x in b) {
    sb.write(x.toRadixString(16).padLeft(2, '0'));
  }
  return sb.toString();
}

Uint8List fromHex(String hex) {
  final h = hex.replaceAll(RegExp(r'^0x'), '');
  final out = <int>[];
  for (var i = 0; i < h.length; i += 2) {
    out.add(int.parse(h.substring(i, i + 2), radix: 16));
  }
  return Uint8List.fromList(out);
}
