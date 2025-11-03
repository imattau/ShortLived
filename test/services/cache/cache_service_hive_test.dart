import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:nostr_video/data/models/author.dart';
import 'package:nostr_video/data/models/post.dart';
import 'package:nostr_video/services/cache/cache_service_hive.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late Directory tempDir;

  setUp(() async {
    tempDir = await Directory.systemTemp.createTemp('cache_service_hive_test');
    await Hive.close();
  });

  tearDown(() async {
    await Hive.close();
    if (tempDir.existsSync()) {
      await tempDir.delete(recursive: true);
    }
  });

  Post _post(int i) => Post(
        id: 'p$i',
        author: Author(pubkey: 'pk$i', name: 'name $i', avatarUrl: 'a$i'),
        caption: 'caption $i',
        tags: const ['demo'],
        url: 'https://example.com/$i.mp4',
        thumb: 'https://example.com/$i.jpg',
        mime: 'video/mp4',
        width: 1,
        height: 1,
        duration: 1.0 + i,
        likeCount: i,
        commentCount: i,
        repostCount: i,
        createdAt: DateTime.fromMillisecondsSinceEpoch(i * 1000, isUtc: true),
      );

  test('save and load round trip enforces limit', () async {
    final cache = CacheServiceHive(
      maxPosts: 3,
      hive: Hive,
      initializer: (hive) async {
        hive.init(tempDir.path);
      },
    );

    await cache.init();
    await cache.savePosts(List.generate(5, _post));

    final loaded = await cache.loadCachedPosts();
    expect(loaded, hasLength(3));
    expect(loaded.map((p) => p.id).toList(), ['p0', 'p1', 'p2']);
    expect(loaded.first.author.name, 'name 0');
    expect(loaded.first.likeCount, 0);
    expect(loaded.first.thumb, 'https://example.com/0.jpg');
  });

  test('falls back to in-memory store when Hive unavailable', () async {
    final cache = CacheServiceHive(
      maxPosts: 2,
      initializer: (_) async {
        throw Exception('boom');
      },
    );

    await cache.init();
    await cache.savePosts(List.generate(2, _post));
    await cache.cacheThumb('p0', 'thumb');

    final loaded = await cache.loadCachedPosts();
    expect(loaded, hasLength(2));
    expect(loaded.first.id, 'p0');
    expect(loaded.first.thumb, 'thumb');
  });
}
