import 'package:flutter_test/flutter_test.dart';
import 'package:nostr_video/utils/count_format.dart';

void main() {
  test('parse and format counts', () {
    expect(parseCount('12.3k'), 123);
    expect(parseCount('1,234'), 1234);
    expect(formatCount(999), '999');
    expect(formatCount(1000), '1.0k');
    expect(formatCount(1534000), '1.5m');
  });
}
