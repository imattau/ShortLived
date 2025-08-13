import 'package:flutter_test/flutter_test.dart';
import 'package:nostr_video/services/nostr/backoff.dart';

void main() {
  test('exponential backoff caps at max', () {
    final b = Backoff(base: const Duration(seconds: 1), max: const Duration(seconds: 8));
    expect(b.at(0), const Duration(seconds: 1));
    expect(b.at(1), const Duration(seconds: 2));
    expect(b.at(2), const Duration(seconds: 4));
    expect(b.at(3), const Duration(seconds: 8));
    expect(b.at(4), const Duration(seconds: 8));
  });
}
