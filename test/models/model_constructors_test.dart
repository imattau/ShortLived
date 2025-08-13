import 'package:flutter_test/flutter_test.dart';
import 'package:nostr_video/data/models/author.dart';
import 'package:nostr_video/data/models/file_meta.dart';

void main() {
  test('Author constructs', () {
    const a = Author(pubkey: 'pk', name: 'n', avatarUrl: 'u');
    expect(a.following, false);
  });

  test('FileMeta constructs', () {
    const m = FileMeta(
      url: 'u',
      thumb: 't',
      mime: 'video/mp4',
      width: 1080,
      height: 1920,
      duration: 1.2,
    );
    expect(m.mime, 'video/mp4');
  });
}
