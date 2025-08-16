class FeedItem {
  final String url;
  final String caption;
  String likeCount;
  String commentCount;
  String repostCount;
  String shareCount;
  String zapCount;
  FeedItem({
    required this.url,
    required this.caption,
    this.likeCount = '0',
    this.commentCount = '0',
    this.repostCount = '0',
    this.shareCount = '0',
    this.zapCount = '0',
  });
}

final demoFeed = <FeedItem>[
  FeedItem(
    url: 'https://flutter.github.io/assets-for-api-docs/assets/videos/bee.mp4',
    caption: 'Enjoying a sunny day #nature #sydney #nostr',
    likeCount: '12.3k',
    commentCount: '885',
    repostCount: '97',
    shareCount: '87',
    zapCount: '42',
  ),
  FeedItem(
    url: 'https://flutter.github.io/assets-for-api-docs/assets/videos/butterfly.mp4',
    caption: 'Moments in the garden #macro #nostr',
    likeCount: '9.1k',
    commentCount: '431',
    repostCount: '51',
    shareCount: '32',
    zapCount: '15',
  ),
  FeedItem(
    url: 'https://flutter.github.io/assets-for-api-docs/assets/videos/bee.mp4',
    caption: 'Looping demo clip #dev',
    likeCount: '2.0k',
    commentCount: '101',
    repostCount: '10',
    shareCount: '8',
    zapCount: '3',
  ),
];

