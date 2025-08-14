import 'package:flutter_test/flutter_test.dart';
import 'package:nostr_video/services/search/search_parser.dart';

void main() {
  test('parses hashtag', () {
    expect(SearchParser.parseHashtag('#Cats'), 'cats');
    expect(SearchParser.parseHashtag('  hello #rail_safety '), 'rail_safety');
  });
  test('parses author', () {
    expect(SearchParser.parseAuthor('f'.padLeft(64, 'a'))!.length, 64);
    expect(
      SearchParser.parseAuthor(
        'npub180cvv07tjdrrgpa0j7j7tmnyl2yr6yr7l8j4s3evf6u64th6gkwsyjh6w6',
      ),
      '3bf0c63fcb93463407af97a5e5ee64fa883d107ef9e558472c4eb9aaaefa459d',
    );
  });
  test('parses text', () {
    expect(SearchParser.parseText('  hello world '), 'hello world');
    expect(SearchParser.parseText('#tag'), isNull);
  });
}
