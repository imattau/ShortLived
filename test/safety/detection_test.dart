import 'package:flutter_test/flutter_test.dart';
import 'package:nostr_video/services/safety/content_safety_service.dart';
import 'package:nostr_video/services/settings/settings_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:nostr_video/data/models/post.dart';
import 'package:nostr_video/data/models/author.dart';

class _SettingsHarness extends SettingsService {
  _SettingsHarness(super.prefs);
}

void main() async {
  TestWidgetsFlutterBinding.ensureInitialized();
  SharedPreferences.setMockInitialValues({});
  final sp = await SharedPreferences.getInstance();
  final s = _SettingsHarness(sp);
  final svc = ContentSafetyService(s);

  final p1 = Post(
    id: '1',
    author: const Author(pubkey: 'a', name: 'a', avatarUrl: ''),
    caption: 'nice #nsfw art',
    tags: const [],
    url: 'u',
    thumb: 't',
    mime: 'video/mp4',
    width: 1,
    height: 1,
    duration: 1,
    createdAt: DateTime.now(),
  );

  test('detects hashtag match', () {
    expect(svc.isSensitive(p1), true);
  });

  test('manual mark forces sensitive', () async {
    await s.addSensitiveMark('1');
    expect(svc.isSensitive(p1), true);
  });
}
