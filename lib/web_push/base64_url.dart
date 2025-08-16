import 'dart:convert';
import 'dart:typed_data';

/// Decode a base64url string (no padding) into bytes.
Uint8List base64UrlToBytes(String s) {
  var b64 = s.replaceAll('-', '+').replaceAll('_', '/');
  while (b64.length % 4 != 0) {
    b64 += '=';
  }
  return Uint8List.fromList(base64Decode(b64));
}
