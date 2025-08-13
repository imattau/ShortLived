import 'author.dart';

class Post {
  final String id;
  final Author author;
  final String caption;
  final List<String> tags;
  final String url;
  final String thumb;
  final String mime;
  final int width;
  final int height;
  final double duration;
  final int likeCount;
  final int commentCount;
  final DateTime createdAt;

  const Post({
    required this.id,
    required this.author,
    required this.caption,
    required this.tags,
    required this.url,
    required this.thumb,
    required this.mime,
    required this.width,
    required this.height,
    required this.duration,
    this.likeCount = 0,
    this.commentCount = 0,
    required this.createdAt,
  });

  /// NIP-94 file tags to attach to a kind:1 post
  List<List<String>> toNip94Tags() => [
    ['t', mime],
    ['url', url],
    ['dim', '${width}x$height'],
    ['dur', duration.toStringAsFixed(1)],
    ['thumb', thumb],
  ];
}
