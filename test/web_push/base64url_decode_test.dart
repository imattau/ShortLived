import 'package:flutter_test/flutter_test.dart';
import 'package:nostr_video/web_push/web_push.dart';

void main() {
  test('base64url decode pads correctly', () {
    // "test" -> dGVzdA==
    // url-safe without padding:
    final bytes = base64UrlToBytes('dGVzdA');
    expect(bytes.length, 4);
  });
}
