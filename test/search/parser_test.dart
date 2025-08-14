import 'package:flutter_test/flutter_test.dart';
import 'package:nostr_video/services/search/search_parser.dart';

void main() {
  test('parses hashtag', () {
    expect(SearchParser.parseHashtag('#Cats'), 'cats');
    expect(SearchParser.parseHashtag('  hello #rail_safety '), 'rail_safety');
  });
  test('parses author', () {
    expect(SearchParser.parseAuthor('f'.padLeft(64, 'a'))!.length, 64);
    expect(SearchParser.parseAuthor('npub1qqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqq'), isNotNull);
  });
  test('parses text', () {
    expect(SearchParser.parseText('  hello world '), 'hello world');
    expect(SearchParser.parseText('#tag'), isNull);
  });
}
