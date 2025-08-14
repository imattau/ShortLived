class SearchQuery {
  final String raw;          // what user typed
  final String? hashtag;     // #tag
  final String? authorHex;   // hex pubkey (64)
  final String? text;        // free text
  SearchQuery({required this.raw, this.hashtag, this.authorHex, this.text});
}

class SearchResultItem {
  final String eventId;
  final String title;    // first 80 chars of content or caption
  final String subtitle; // @author, time, tag
  SearchResultItem({required this.eventId, required this.title, required this.subtitle});
}
